#*********************************************************
#
# Copyright (c) Microsoft. All rights reserved.
# This code is licensed under the Microsoft Public License.
# THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
# IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
# PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
#
#*********************************************************

# =============================================================================
# OVERVIEW
#
# Hyper-V Network Virtualization (WNV) virtualizes the VM networks by 
# associating each VM IP address (Customer Address, CA) with a corresponding
# physical IP address used on the actual packets on the wire (Provider Address,
# PA). Each VM packet is transformed (rewritten or encapsulated) from a CA
# packet to PA packet before the packet is transmitted onto the physical
# network. On the destination host, the packet is transformed back with
# matching rules from PA packet to CA packet before it is delivered to the
# destination VM.
#
# The WNV module operates on the packets based on the virtualization policy
# rules provisioned from management servers such as SCVMM (System Center
# Virtual Machine Manager). These policy rules define the mapping of CA:PA for
# each VM, the corresponding virtualization mechanism (rewrite/encap), and
# which customer virtual subnet these rules are for. Additionally, the
# virtualization rules also defines routing topology between customer virtual
# subnets, and between WNV virtual subnets and non-WNV networks (cross premise,
# virtual-to-physical resources, etc.).
#
# The rough packet flows from the VM to the physical networks:
#
# (1) From within the VM: The VM is configured with IP address and MAC address,
#     e.g., CA1 and MAC1, and a default gateway CAGW. The VMs send and receive
#     packets in the CA address space, e.g., from CA1 to CA2 for Blue Corp. WNV
#     module is located in the Hyper-V network stack, between virtual switch
#     and physical or teamed NIC. The WNV policy rules define how WNV module
#     processes a VM packet. These rules are provisioned independently to how
#     the VMs are configured. So if the rules do not match a VM's network
#     configuration (IP, MAC, default routes, etc.), the packets will NOT be
#     processed correctly. Unfortunately, due to the nature of IaaS
#     (Infrastructure as a Service), there is no easy way to verify one against
#     the other.
#
# (2) A VM packet in CA space is sent from VM through vNIC to the virtual
#     switch. Each virtual switch port MUST be configured with a
#     VirtualSubnetID ACL, which isolates intra-host traffic between different
#     tenant subnets. VirtualSubnetID (VSID) is a unique identifier, ranges
#     from 4096 to 2^24-2, for a customer virtual subnet. VSID MUST be unique
#     within a single WNV domain. Once a virtual switch port is configured with
#     the VSID port ACL, the virtual switch will add a VirtualSubnetID OOB
#     (Out-Of-Band data) with the packet, which will be used by the WNV module
#     to determine if a packet belongs to a WNV VM, a pass-through VM, or host
#     partition. If a VSID is NOT configured, the VSID will default to 0, which
#     is pass-through for WNV. WNV module will NOT process the packet with VSID
#     of 0. When the parent OS is also using the virtual switch (when the
#     "Shared by Management OS" is checked in the virtual switch manager), this
#     is the default mode to NOT virtualize parent OS traffic. The
#     VirtualSubnetID is set below in the example with the Set-VMNetworkAdapter
#     cmdlet on each VM port. It only needs to be set once for the lifetime of
#     the VM, live migration will migrate the VSID with the VM so it does not
#     need to be set again on the destination host.
#
# (3) A VM packet reaches the WNV module with the VSID OOB, the WNV module
#     looks up the corresonding virtualization policy rules provisioned by
#     SCVMM (or PowerShell scripts) based on VSID, CA address, and MAC address.
#     These are the virtualization policy rules shown in the example below that
#     define how a VM packet is processed:
#
#     (a) Customer Address Rule (NetVirtualizationLookupRecord): defines the
#         mapping for a VM CA. For each VM CA (defined by VirtualSubnetID, CA,
#         and MAC), the corresponding PA and virtualization machanism are 
#         pecified by the rule.
#     (b) Customer Route (NetVirtualizationCustomerRoute): defines the customer
#         VM subnet topology and forwarding rules. For each customer destination
#         prefix (defined by VirtualSubnetID, RoutingDomainID, and destination
#         prefix), a customer route specifies the corresponding next hop router
#         (gateway) address. The RoutingDomainID specifies the subnets that are
#         routable/reachable from each other. Each VirtualSubnetID MUST belong
#         to one and only one RoutingDomainID. Each RoutingDomainID can contain
#         one or more VirtualSubnetIDs.
#     (c) Provider Address Rule (NetVirtualizationProviderAddress): defines the
#         Provider Addresses assigned on the corresponding host for VM CA's. If
#         a VM on a host is mapped to PA1, PA1 MUST be assigned on the WNV
#         module using this rule. This rule tells the WNV module that a PA is
#         assigned on the host, so that the WNV module can use the PA to send
#         packets, and it MUST receive packets destined to the PA.
#     (d) Provider Route Rule (NetVirtualizationProviderRoute): defines the PA
#         forwarding rules and next hop gateways so the WNV module knows how to
#         send PA packets.
#
# (4) On the inbound path, the reverse processing flow happens: PA packets are
#     delivered from physical/teamed NIC to the WNV module, which looks up the
#     virtualization policy rules to determine if a packet is valid (by finding
#     the corresponding Lookup records); the transformation mechanism in the
#     Lookup record (rewrite/encapsulate-decapsulate) is used to transform the
#     packet from PA packets back to CA packets. Then the VirtualSubnetID OOB
#     of the Lookup record is added to the packet and indicated to the virtual
#     switch. The virtual switch then send the packet to the corresponding
#     virtual switch port, which will verify the VSID OOB (only allow if
#     matched) before the packet is indicated to the VM.
#
# =============================================================================
#
# TOPOLOGY
#
# The following script sets up a simple topology with a customer virtual subnet
# and an edge gateway that bridges Network Virtualized VMs to non-Network-
# Virtualized servers.
#
# Figure 1 shows the virtual topology:
#
# +----------+  +----------+  +--------------------+  +-----------+
# |BlueS1-VM1|  |BlueS1-VM2|  |      Blue-GW       |  |   Corp1   |
# | 10.0.0.5 |  | 10.0.0.7 |  |10.0.1.2  10.222.0.2|  |10.222.0.3 |
# +----------+  +----------+  +--------------------+  +-----------+
#      |             |            |          |              |
#      |             |            |          |              |
#  +======================+    +=====+     {=============================}
#         10.0.0.0/24        10.0.1.0/24  {    Corpnet (non-virtual)      }
#           |                     |        {                             }
#           |  +...............+  |         {============================}
#           +--:  WNV Virtual  :--+
#              :    Gateway    :
#              +...............+
#
# In this virtual topology, there is one virtual subnet with 2 VMs: BlueS1-VM1,
# BlueS1-VM2, belonging to the subnet prefix of 10.0.0.0/24. The edge gateway
# Blue-GW bridges the virtual subnet 10.0.0.0/24 and the non-virtualized
# Corpnet, in this example represented by the 10.222.0.0/24 subnet.
#
# Figuire 2 shows the actual deployment topology:
#
# +----------+                  +----------+                  #===============================#               
# |BlueS1-VM1|                  |BlueS1-VM2|                  #     10.0.1.2+---------------+ #
# | 10.0.0.5 |                  | 10.0.0.7 |                  # VSID +------|   (Blue-GW)   | #
# +----------+                  +----------+                  # 5000 |      |               | #
#      | VSID                        | VSID                   # +---------+ |   Parent OS   | #
#      | 6000                        | 6000                   # | V.Switch| | Network Stack | #
# +========================+    +========================+    # +---------+ +---------------+ #      +------------+
# #    |--[V.Switch]-|     #    #    |--[V.Switch]-|     #    #      |     10.222.0.2|        #      |   Corp1    |
# #        [WNVNIC]        #    #        [WNVNIC]        #    #  [WNVNIC]        [CorpNIC]    #      | 10.222.0.3 |
# +========================+    +========================+    +===============================+      +------------+
# Host1       | PA=             Host2       | PA=              Host3|PA=             |               Host4 |
#             | 192.168.1.101               | 192.168.1.102         |192.168.1.103   |           (optional)|
#             +-----------------------------+-----------------------+                +------[[CORPNET]]----+---->>
#              Datacenter Network Fabric (Virtualization PA Network)                    Non-Virtualized Corpnet
#
# In the actual deployment topology, there are 4 physical servers connected to
# 2 IP subnets as shown above:
#
# 1. Datacenter Network (192.168.1.0/24 subnet)
#    o Host1: BlueS1-VM1
#    o Host2: BlueS1-VM2
#    o Host3: Dual-homed - Connect one NIC (WNVNIC) to the Datacenter Network
# 2. Corpnet (10.222.0.0/24, not network virtualized)
#    o Host3: Dual-homed - Connect the second NIC (CorpNIC) to Corpnet
#    o Host4: Optional - emulates corp physical machines to test connectivity
#
# The edge gateway, Host3/Blue-GW, is a dual-homed server running Windows
# Server 2012. It uses the Parent OS Network Stack, shown in the "Blue-GW" box
# in Figure 2, to forward/route traffic between the virtual subnet
# (10.0.0.0/24) and the corp subnet (10.222.0.0/24). The detailed configuration
# is listed in the Instructions section.
#
# =============================================================================
# INSTRUCTIONS
#
# [1] Prepare the three hosts, and connect the hosts as shown in Figure 2.
#     (Host4 is optional.)
# [2] Install Windows Server 2012 (Standard or Datacenter)
#     (a) Rename the NICs used in the topology above to WNVNIC on each host.
#         For Host3, rename the physical NIC connected to datacenter network to
#         WNVNIC.
#     (b) Join the hosts to the same domain. (PowerShell remoting requires the
#         script to be run with a domain credential that has admin previlege on
#         ALL hosts.)
#     (c) Install Hyper-V role:
#         PS:> Install-WindowFeature Hyper-V, RSAT-Hyper-V-Tools, Hyper-V-Tools, Hyper-V-PowerShell
#     (d) Create a virtual switch on WNVNIC connected with the topology above.
#     (e) On Host3:
#         o Virtual switch
#           - Create a virtual switch on WNVNIC as described above
#           - Check "Allow management operating system to share this network
#             adapter"
#         o Configure the IP address / MAC address of the vEthernet to the
#           virtual switch as shown in Figure 2
#           - Use "Get-NetIPAddress" to verify if the IP address is correct
#         o Enable forwarding on both the vEthernet interface and CorpNIC
#           - Use "Get-NetAdapter" to find the list all interfaces and indices;
#             e.g., assume the interface indices are 32 and 36.
#           - Use "Set-NetIPInterface" to enable forwarding on these interfaces
#             Set-NetIPInterface -InterfaceIndex 32 -AddressFamily IPv4 -Forwarding Enabled
#             Set-NetIPInterface -InterfaceIndex 36 -AddressFamily IPv4 -Forwarding Enabled
#           - Use "Get-NetIPInterface" to verify if forwarding is enabled
#             properly:
#             Get-NetIPInterface -InterfaceIndex 32 | fl
#             Get-NetIPInterface -InterfaceIndex 36 | fl
#         o Verify routes
#           - Use "Get-NetRoute" to verify the route setup
#           - In this example, there should be 2 onlink routes:
#             > DestinationPrefix: 10.0.0.0/16 ==> NextHop 10.0.1.1, ifIndex 32
#               (assuming the interface index of 10.0.0.2 is 32)
#             > DestinationPrefix: 10.222.0.0/24 ==> NextHop 0.0.0.0, ifIndex 36
#               (assuming the interface index of 10.222.0.2 is 36)
#     (e) [OPTIONAL] Host4 is optional. Adding a Host4 can emulate a non-
#         virtualized system communicating with network-virtualized VMs:
#         o The default gateway of Corp1 MUST be set to 10.222.0.2
#
# [3] Create customer VMs on each host with the following configuration
#     (*) MAC address is configured from Hyper-V, under VM Settings ==>
#         Hardware ==> Network Adapter ==> Advanced Feature (or use PowerShell)
#     (a) Host1
#           BlueS1-VM1: IP=10.0.0.5, MAC=101010101005, default route=10.0.0.1
#     (b) Host2
#           BlueS1-VM2: IP=10.0.0.7, MAC=101010101007, default route=10.0.0.1
#     (c) Host3
#           Blue-GW:    Refer to [2]-(e) above
#           Host vNIC:  IP=10.0.0.2,   MAC=101010101002,   default route=N/A
#           CorpNIC:    IP=10.222.0.2, MAC=(physical MAC), default route=N/A
#     (d) Host4 (optional)
#           IP=10.222.0.3, default route=10.222.0.2
# [4] Edit this script:
#     (a) $Hosts: List the hostnames of your configuration
#     (b) Update the parameters if the values are different:
#         o Provider Addresses
#         o Customer Addresses
#         o MAC addresses
#         o Routes: destination prefixes and next hop gateways
#         o VirtualSubnetIDs and RoutingDomainIDs
#         o VM names
#         o Domain credential (search and replace "DOMAIN\ADMIN")
#     (c) Add new entries if there are more VMs than the topology shown above
# [5] Run the script from any machine in the same domain
# [6] Start all VMs
#
# =============================================================================
# 
# TESTING NETWORK VIRTUALIZATION
#
# Once the script is executed, and the VMs started, follow the procedures below
# to verify if the VMs can communicate with each other.
#
# [1] From within all VMs, open a PowerShell window with Admin privilege
# [2] Create firewall rules to allow ICMP (ping) packets:
#     PS:> New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4
#     PS:> New-NetFirewallRule –DisplayName “Allow ICMPv4-Out” –Protocol ICMPv4 –Direction Outbound
# [3] From BlueS1-VM1, ping IP addresses of BlueS1-VM2, Blue-GW, and Corp1
#     PS:> ping 10.0.0.7
#     PS:> ping 10.0.1.2
#     PS:> ping 10.222.0.2 or 10.222.0.3 (if Corp1 is availble)
#     Note that pinging 10.0.0.1 will not work. Instead, use "arp -a 10.0.0.1"
#     This command should show the MAC address for 10.0.0.1 (10-10-10-10-11-01).
# [4] Repeat the pings from BlueS1-VM2, Blue-GW, and Corp1 to verify pairwise
#     connectivity between all VMs and hosts.
# [5] If the policy and configuration are correct, both pings should see 
#     positive responses from the other VMs
#
# The following PowerShell commands will show the Hyper-V Network
# Virtualization policy:
# 
# On Host1, Host2, or Host3:
# PS: > Get-NetVirtualizationLookupRecord
# PS: > Get-NetVirtualizationCustomerRoute
# PS: > Get-NetVirtualizationProviderAddress
# PS: > Get-VM | Get-VMNetworkAdapter | fl VMName,VirtualSubnetID
# The last one on Host3 should be
# PS:> Get-VM | Get-VMNetworkAdapter -ManagementOS | fl VMName,VirtualSubnetID
#
# =============================================================================
# WNV POLICY
# 
# The WNV policy rules MUST be provisioned before VM communication can start.
# The script is divided into 3 parts:
#
# [1] Provision VM Customer Address and Customer Route rules. In the sample,
#     they are the same on all three hosts. In real deployment, Virtualization
#     Policies are only needed on the hosts where the corresponding VMs are
#     provisioned.
#
# [2] (a) On each host, configure PA Address and PA Route rules: These rules
#         are per host. Each PA can only be assigned on one host, and the
#         corresponding gateway/forwarding rules.
#     (b) On each host, the VirtualSubnetID Port ACLs of the VMs ON THAT HOST
#         MUST be provisioned. THIS IS DONE ONCE PER VIRTUAL SWITCH PORT. In
#         the sample, it is configured in conjunction with the Provider Address
#         and Provider Route configuration on the same host.
#
# =============================================================================
#


Import-Module NetAdapter
Import-Module NetWnv

# All hosts in this setup ==> CHANGE THESE TO YOUR HOST NAMES
$Hosts = "example-host1", "example-host2", "example-host3"

# You must define admin account below
$admin = "DOMAIN\ADMINISTRATOR"

# Some constants
$WNVNIC   = "WNVNIC"
$WNVDRV   = "ms_netwnv"

#
# [1] Configure Customer VM Policy information on all hosts with customer VMs
#
for ($i=0; $i -lt $Hosts.length; $i++) {

    #################################################################################################################
    # Reset WNV module to clean up existing policy
    #(THIS IS NOT THE RECOMMENDED WAY ==> YOU SHOULD REMOVE ALL EXITING WNV POLICY INSTEAD OF RESETTING THE MODULE)
    Write-Host "Configuring WNV on", $Hosts[$i] -ForegroundColor Yellow
    Write-Host "  ==> Enable Network Virtualization Module on", $WNVNIC -ForegroundColor Yellow
    Disable-NetAdapterBinding $WNVNIC -ComponentID $WNVDRV -CimSession $Hosts[$i]
    Enable-NetAdapterBinding  $WNVNIC -ComponentID $WNVDRV -CimSession $Hosts[$i]


    ###########################################################################
    # ==> Routing Domain ID: RDID1 = "{11111111-2222-3333-4444-000000000000}"
    #     o This is defined by VMM, unique per datacenter VMM instance.
    #
    # ==> CA Records to define CA-PA Mappings for each VM
    #
    # VM Name        Host   VSID   CA         PA             MAC              
    # ------------------------------------------------------------------------
    # BlueS1-VM1     Host1  6000   10.0.0.5   192.168.1.101  10-10-10-10-11-05
    # BlueS1-VM2     Host2  6000   10.0.0.7   192.168.1.102  10-10-10-10-11-07
    # BlueS1-DG      N/A    6000   10.0.0.1   192.168.1.111  10-10-10-10-11-01
    # Blue-GW        Host3  5000   10.0.1.2   192.168.1.103  10-10-10-10-10-FF
    # BlueWildcard   Host3  5000   0.0.0.0    192.168.1.103  10-10-10-10-10-FF
    # Blue-GWDG      N/A    5000   10.0.1.1   192.168.1.111  10-10-10-10-10-01
    # 
    # NOTES
    # (1) The wildcard lookup records is needed becuase Blue VMs will be sending
    #     packets to and receiving packets from IP addresses behind the
    #     gateway, Blue-GW. It is not possible to list all those addresses in
    #     the virtualization policy, so a wildcard record is required to match
    #     these outside IP addresses with the Blue-GW PA, MAC, and CA for
    #     validation purposes.
    # (2) The default gateway lookup records are needed to direct the offlink
    #     packets to the WNV module, which has a customer route pointing those
    #     packets to the gateway CA (Blue-GW).
    #	
    # ==> Customer Routes to direct VM traffic
    #
    # DestPrefix   NextHopGW   VSID RDID   Note
    # -------------------------------------------------------------------------
    # 10.0.0.0/16  0.0.0.0     6000 RDID1  [MUST] Onlink route for Blue subnet
	# 10.0.1.0/16  0.0.0.0     5000 RDID1  [MUST] Onlink route for GW subnet
    # 0.0.0.0/0    10.0.0.2    5000 RDID1  Default gateway to point outside
    #                                       traffic to Blue-GW

    # Blue Subnet 1 locator records (VSID=6000)
    New-NetVirtualizationLookupRecord -CustomerAddress "10.0.0.5" -ProviderAddress "192.168.1.101"   -VirtualSubnetID "6000" -MACAddress "101010101105" -Rule "TranslationMethodEncap" -VMName "BlueS1-VM1"   -CimSession $Hosts[$i]
    New-NetVirtualizationLookupRecord -CustomerAddress "10.0.0.7" -ProviderAddress "192.168.1.102"   -VirtualSubnetID "6000" -MACAddress "101010101107" -Rule "TranslationMethodEncap" -VMName "BlueS1-VM2"   -CimSession $Hosts[$i]
    New-NetVirtualizationLookupRecord -CustomerAddress "10.0.0.1" -ProviderAddress "169.254.254.254" -VirtualSubnetID "6000" -MACAddress "101010101101" -Rule "TranslationMethodEncap" -VMName "BlueS1-DG"    -CimSession $Hosts[$i]
    # Blue Subnet 1 route records
    New-NetVirtualizationCustomerRoute -RoutingDomainID "{11111111-2222-3333-4444-000000000000}" -VirtualSubnetID "6000" -DestinationPrefix "10.0.0.0/24" -NextHop "0.0.0.0"    -Metric 255 -CimSession $Hosts[$i]

    # Blue Gateway locator records  (VSID=5000)
    New-NetVirtualizationLookupRecord -CustomerAddress "10.0.1.2" -ProviderAddress "192.168.1.103"   -VirtualSubnetID "5000" -MACAddress "101010101002" -Rule "TranslationMethodEncap" -VMName "Blue-GW"      -CimSession $Hosts[$i]
    New-NetVirtualizationLookupRecord -CustomerAddress "0.0.0.0"  -ProviderAddress "192.168.1.103"   -VirtualSubnetID "5000" -MACAddress "101010101002" -Rule "TranslationMethodEncap" -VMName "BlueWildcard" -CimSession $Hosts[$i]
    New-NetVirtualizationLookupRecord -CustomerAddress "10.0.1.1" -ProviderAddress "169.254.254.254" -VirtualSubnetID "5000" -MACAddress "101010101001" -Rule "TranslationMethodEncap" -VMName "Blue-GWDG"    -CimSession $Hosts[$i]
    # Blue Gateway route records
    New-NetVirtualizationCustomerRoute -RoutingDomainID "{11111111-2222-3333-4444-000000000000}" -VirtualSubnetID "5000" -DestinationPrefix "10.0.1.0/24" -NextHop "0.0.0.0"    -Metric 255 -CimSession $Hosts[$i]
    New-NetVirtualizationCustomerRoute -RoutingDomainID "{11111111-2222-3333-4444-000000000000}" -VirtualSubnetID "5000" -DestinationPrefix "0.0.0.0/0"   -NextHop "10.0.1.2"   -Metric 255 -CimSession $Hosts[$i]

}

#
# [2] Configure the Host Provider Addresses and Routes required for this setup
#
#   Host    Hostname       PA                 Default_PA_GW  VM:VirtualSubnetID
#   -------------------------------------------------------------------------------------------------------------------------------
#   Host1   example-host1  192.168.1.101/24   192.168.1.1    BlueS1-VM1:6000
#   Host2   example-host2  192.168.1.102/24   192.168.1.1    BlueS1-VM2:6000
#   Host3   example-host3  192.168.1.103/24   192.168.1.1    Blue-GW:   5000

  $cred = Get-Credential $admin

  # [2-1] Host1
  #
  # (a) Configure Provider Address and Route:
  #     Get the interface, assign PA and default gateway
        $iface = Get-NetAdapter $WNVNIC -CimSession $Hosts[0]
        New-NetVirtualizationProviderAddress -InterfaceIndex $iface.InterfaceIndex -ProviderAddress "192.168.1.101" -PrefixLength 24 -CimSession $Hosts[0]
        New-NetVirtualizationProviderRoute -InterfaceIndex $iface.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -NextHop "192.168.1.1" -CimSession $Hosts[0]
  # (b) Set VirtualSubnetID on the virtual switch ports
        Invoke-Command -ComputerName $Hosts[0] -Credential $cred {
          Get-VMNetworkAdapter "BlueS1-VM1" | where {$_.MacAddress -eq "101010101105"} | Set-VMNetworkAdapter -VirtualSubnetID 6000;
        }

  # [2-2] Host2
  #
  # (a) Configure Provider Address and Route:
  #     Get the interface, assign PA and default gateway
        $iface = Get-NetAdapter $WNVNIC -CimSession $Hosts[1]
        New-NetVirtualizationProviderAddress -InterfaceIndex $iface.InterfaceIndex -ProviderAddress "192.168.1.102" -PrefixLength 24 -CimSession $Hosts[1]
        New-NetVirtualizationProviderRoute   -InterfaceIndex $iface.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -NextHop "192.168.1.1" -CimSession $Hosts[1]
  # (b) Set VirtualSubnetID on the virtual switch ports
        Invoke-Command -ComputerName $Hosts[1] -Credential $cred {
          Get-VMNetworkAdapter "BlueS1-VM2" | where {$_.MacAddress -eq "101010101107"} | Set-VMNetworkAdapter -VirtualSubnetID 6000;
        }

  # [2-3] Host3
  #
  # (a) Configure Provider Address and Route:
  #     Get the interface, assign PA and default gateway
        $iface = Get-NetAdapter $WNVNIC -CimSession $Hosts[2]
        New-NetVirtualizationProviderAddress -InterfaceIndex $iface.InterfaceIndex -ProviderAddress "192.168.1.103" -PrefixLength 24 -CimSession $Hosts[2]
        New-NetVirtualizationProviderRoute   -InterfaceIndex $iface.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -NextHop "192.168.1.1" -CimSession $Hosts[2]
  # (b) Set VirtualSubnetID on the virtual switch ports
        Invoke-Command -ComputerName $Hosts[2] -Credential $cred {
          Get-VMNetworkAdapter -ManagementOS | where {$_.MacAddress -eq "101010101002"} | Set-VMNetworkAdapter -VirtualSubnetID 5000;
        }
