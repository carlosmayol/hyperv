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

# Version 1.0

# ===============================================================================================================================
# OVERVIEW
#
# Hyper-V Network Virtualization (WNV) virtualizes the VM networks by associating each VM IP address (Customer Address, CA) with
# a corresponding physical IP address (Provider Address, PA) used on the actual packets on the wire. Each VM packet is transformed
# (rewritten or encapsulated) from a CA packet to PA packet before the packet is transmitted onto the physical network, and is
# transformed back with matching rules from PA packet to CA packet before the packet is sent to the destination VM.
#
# The WNV module operates on the packets based on the virtualization policy rules provisioned from management servers such as
# System Center Virtual Machine Manager (SCVMM). These policy rules define the mapping of CA:PA for each VM, the corresponding
# virtualization mechanism (rewrite/encap), and which customer subnet these rules are for. Additionally, the virtualization
# rules also define routing topology between customer virtual subnets, and between WNV virtual subnets and non-WNV networks
# (cross premise, virtual-to-physical resources, etc.)
#
# The high level packet flows from the VM to the physical networks:
#
# (1) From within the VM: The VM is configured with a CA IP address, MAC address, and typically, a default
#     gateway CAGW. The VMs send and receive packets in the CA address space (CA space), e.g., from CA1 to CA2 for Blue Corp. WNV
#     module is located in the Hyper-V network stack, between the virtual switch and the physical/teamed NIC. The WNV policy rules
#     define how the WNV module processes a VM packet. These rules are provisioned independently to how the VMs are configured. So
#     if the rules do not match a VM's network configuration (IP, MAC, default gateways, etc.), the packets will NOT be processed
#     correctly. No VM may have a CA IP address that is the lowest of the prefix range for the virtual subnet. For example, if the
#     CA virtual subnet is 10.2.3.0/24, then the lowest IP address of the range is 10.2.3.1, which is reserved
#     by the WNV module as the default gateway address for the virtual subnet. This IP address is reserved for the gateway.
#
# (2) A VM packet in CA space is sent from VM through vNIC (virtual network adapter) to the virtual switch. Each virtual switch
#     port MUST be configured with a VirtualSubnetID ACL, which isolates intra-host traffic between different customer subnets.
#     VirtualSubnetID (VSID) is a unique identifier (4096 - 2^24-2) for a customer virtual subnet. VSID MUST be unique within
#     a single WNV domain. Once a virtual switch port is configured with the VSID port ACL, the virtual switch will add a
#     VirtualSubnetID OOB (Out-Of-Band data) with the packet, which will be used by the WNV module to determine if a packet
#     belongs to a WNV VM, a pass-through (exempt) VM, or host partition. If a VSID is NOT configured, the VSID will default to 0,
#     which is pass-through for WNV. WNV module will NOT process the packet with VSID=0. When the parent OS is also using the
#     virtual switch (when the "Shared by Management OS" is checked), this is the default mode to NOT virtualize parent OS traffic.
#     The VirtualSubnetID is set below in the example with the "Set-VMNetworkAdapter" cmdlet on each VM port. It only needs to be
#     set once for the lifetime of the VM; live migration will migrate the VSID with the VM so it does not need to be set again
#     on the destination host. Note that CA VLAN and VSID are mutually exclusive so VM's may not have VLANs.
#
# (3) A VM packet reaches the WNV module with the VSID OOB, the WNV module looks up the corresonding virtualization policy rules
#     provisioned by SCVMM beforehand based on the OOB, packet CA, and MAC address. These are the virtualization policy rules
#     shown in the example below that define how a VM packet is processed:
#
#     (a) Customer Address Rule (NetVirtualizationLookupRecord): defines the mapping for a VM CA. For each VM CA (defined by
#         VirtualSubnetID, CA, and MAC), the corresponding PA and virtualization machanism are specified by the rule.
#     (b) Customer Route (NetVirtualizationCustomerRoute): defines the customer VM subnet topology and forwarding rules. For each
#         customer destination prefix (defined by VirtualSubnetID, RoutingDomainID, and destination prefix), the rule specifies the
#         corresponding next hop gateway address. The RoutingDomainID specifies the subnets that are routable/reachable from each
#         other. Each VirtualSubnetID MUST belong to one and only one RoutingDomainID. Each RoutingDomainID can contain one or more
#         VirtualSubnetIDs.
#     (c) Provider Address Rule (NetVirtualizationProviderAddress): defines the Provider Addresses assigned on the corresponding host
#         for VM CA's. If a VM on a host is mapped to PA1, PA1 MUST be assigned on the WNV module using this rule. This rule tells
#         the WNV module that a specific PA is assigned on the host, and the WNV module can use the PA to send packets, and MUST
#         receive packets destined to the PA.
#     (d) Provider Route Rule (NetVirtualizationProviderRoute): defines the PA forwarding rules and next hop gateways so the WNV
#         module knows how to send PA packets.
#
# (4) On the inbound path, the reverse processing flow happens: PA packets indicated from physical/teamed NIC to the WNV module,
#     which looks up the virtualization policy rules to determine if a packet is valid (by finding the corresponding rules), and
#     the corresponding transformation (rewrite/encapsulate) required to transform the packet from PA to CA. Then the
#     VirtualSubnetID OOB of the rule is added to the packet and indicated to the virtual switch. The virtual switch then send
#     the packet to the corresponding virtual switch port, which will verify the VSID OOB (only allow if matched) before the
#     packet is indicated to the VM.
#
# ===============================================================================================================================
#
# Topology:
#
# The following script sets up a very simple topology with 4 VMs from 2 virtual subnets on 2 hosts as shown below:
#
#    +---------+  +---------+          +---------+  +---------+
#    |  Blue1  |  |  Red1   |          |  Blue2  |  |  Red2   |
#    |10.0.0.5 |  |10.0.0.5 |          |10.0.0.7 |  |10.0.0.7 |
#    +---------+  +---------+          +---------+  +---------+
#        | VSID       | VSID               | VSID       | VSID
#        | 5001       | 6001               | 5001       | 6001
#    +======================+          +======================+
#    #        Host 1        #          #        Host 2        #
#    #                      #          #                      #
#    +======================+          +======================+
#    PA=         |                                  | PA=
#    192.168.4.11|                                  | 192.168.4.22
#                +----------------------------------+
#
# Blue1 and Blue2 form the one virtual subnet and Red1 and Red2 form the second virtual subnet. Blue and Red VMs are using
# overlapping IP addresses, but are separated by different virtual subnet IDs and RougingDomainIDs below that define the
# isolation boundary. The PA's designated for each VM CA are shown at the bottom.
#
# 
# ===============================================================================================================================
# INSTRUCTIONS
#
# [1] Prepare the two hosts, and connect the hosts as the topology above (same Ethernet segment).
# [2] Install Windows Server 8
#     (a) Rename the NICs used in the topology above to WNVNIC on each host.
#     (b) Join the hosts to the same domain. (PowerShell remoting requires the user to run the script with a domain credential that
#         has admin previlege on ALL hosts.)
#     (c) Install Hyper-V role.
#     (d) Create a virtual switch on the NIC connected with the topology above (WNVNIC).
#     (e) [OPTIONAL] For live migration, the VMs MUST use Hyper-V over SMB. Prepare another Windows Server as an SMB file server to
#         store VHD files and VM configuration files.
# [3] Create customer VMs on each host with the following configuration
#     (*) MAC address is configured from Hyper-V, under VM Settings ==> Hardware ==> Network Adapter ==> Advanced Feature (or use PS)
#     (a) Host1
#           Blue1:   IP=10.0.0.5, MAC=06-06-00-00-00-05, default route=10.0.0.1
#           Red1:    IP=10.0.0.5, MAC=08-08-00-00-00-05, default route=10.0.0.1
#     (b) Host2
#           Blue2:   IP=10.0.0.7, MAC=06-06-00-00-00-07, default route=10.0.0.1
#           Red2:    IP=10.0.0.7, MAC=08-08-00-00-00-07, default route=10.0.0.1
# [4] Edit this script:
#     (a) $Hosts: List the hostnames of your configuration
#     (b) Update the parameters if the values are different from above:
#         o Provider Addresses
#         o Customer Addresses
#         o MAC addresses
#         o Routes: destination prefixes and next hop gateways
#         o VirtualSubnetIDs and RoutingDomainIDs
#         o VM names
#         o Domain credential (search and replace "domain\user")
#     (c) Add new entries if there are more VMs than the topology shown above
# [5] Run the script from any machine in the same domain
# [6] Start all VMs
# 
# ==============================================================================================================================
# 
# TESTING NETWORK VIRTUALIZATION
#
# Once the script is executed, and the VMs started, follow the procedures below to verify if the VMs can communicate
# with each other.
#
# [1] From within all VMs, open a PowerShell window with Admin privilege
# [2] Create firewall rules to allow ICMP (ping) packets:
#     PS:> New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4
#     PS:> New-NetFirewallRule –DisplayName “Allow ICMPv4-Out” –Protocol ICMPv4 –Direction Outbound
# [3] From Blue1, ping Blue2's IP address:
#     Blue1 PS:> ping 10.0.0.7
# [4] From Red1, ping Red2's IP address:
#     Red1 PS:>  ping 10.0.0.7
# [5] If the policy and configuration are correct, both pings should see positive responses from the other VMs
#
# The following PowerShell commands will show the Hyper-V Network Virtualization policy:
# 
# On Host 1 or Host 2:
# PS: > Get-NetVirtualizationLookupRecord
# PS: > Get-NetVirtualizationCustomerRoute
# PS: > Get-NetVirtualizationProviderAddress
# PS: > Get-VM | Get-VMNetworkAdapter | fl VMName,VirtualSubnetID
#
# ===============================================================================================================================
# WNV POLICY
# 
# The WNV policy rules MUST be provisioned before VM communication can start. The script is divided into 3 parts:
#
# [1] Provision VM Customer Address and Customer Route rules. In the sample, they are the same on all hosts. In real deployment,
#     Blue Rules are only needed on the hosts with Blue VMs, and vice versa for the Red Rules.
#
# [2-a] On each host, configure PA Address and PA Route rules: These rules are per host. Each PA can only be assigned on one host, and
#     its corresponding gateway/forwarding rules.
#
# [2-b] On each host, the VirtualSubnetID Port ACLs of the VMs ON THAT HOST MUST be provisioned. THIS IS DONE ONCE PER VIRTUAL SWITCH
#     PORT. In the sample, it is configured in conjunction with the Provider Address and Provider Route configuration on the same host.
#
# ===============================================================================================================================

Import-Module NetAdapter
Import-Module NetWnv

# All hosts in this setup ==> CHANGE THESE TO YOUR HOST NAMES
$Hosts = "example-host1",    "example-host2"

# You must define admin account below
$admin = "DOMAIN\ADMIN"

# Some constants
# Name of the NIC where the Virtual Switch is bound to and WNV will be utilized:
$WNVNIC   = "WNVNIC"
# Name of the WNV module ==> DO NOT CHANGE THIS
$WNVDRV   = "ms_netwnv"

#
# [1] Configure Customer VM Policy information on all hosts with customer VMs
#
for ($i=0; $i -lt $Hosts.length; $i++) {

    #################################################################################################################
    # Reset WNV module to clean up existing policy
    # (THIS IS NOT THE RECOMMENDED WAY ==> YOU SHOULD REMOVE ALL EXITING WNV POLICY INSTEAD OF RESETTING THE MODULE)
    Write-Host "Configuring WNV on", $Hosts[$i] -ForegroundColor Yellow
    Write-Host "  ==> Enable Network Virtualization Module on", $WNVNIC -ForegroundColor Yellow
    Disable-NetAdapterBinding $WNVNIC -ComponentID $WNVDRV -CimSession $Hosts[$i]
    Enable-NetAdapterBinding  $WNVNIC -ComponentID $WNVDRV -CimSession $Hosts[$i]
	
    #################################################################################################################
    # Blue Virtual Network Information
    #
    # RoutingDomainID="{11111111-2222-3333-4444-000000005001}"
    # VirtualSubnetID]=5001 
    # (Both RDID and VSID are defined by administrators, MUST be unique in the datacenter)
    #
    # [Customer Addresses]
    # VM Name      Host   VSID  CA        PA             MAC                DefaultGW  
    # ---------------------------------------------------------------------------------
    # Blue1        Host1  5001  10.0.0.5  192.168.4.11   06-06-00-00-00-05  10.0.0.1
    # Blue2        Host2  5001  10.0.0.7  192.168.4.22   06-06-00-00-00-07  10.0.0.1
    # 
    # [Customer Routes]
    # DestPrefix   NextHopGW  Note
    # -----------------------------------------------------------------------------------
    # 10.0.1.0/24  0.0.0.0    Onlink route for Blue subnet

    # Add the locator records for Blue subnet 
    New-NetVirtualizationLookupRecord -VirtualSubnetID "5001" -CustomerAddress "10.0.0.5" -ProviderAddress "192.168.4.11" -MACAddress "060600000005" -Rule "TranslationMethodEncap"  -CimSession $Hosts[$i]
    New-NetVirtualizationLookupRecord -VirtualSubnetID "5001" -CustomerAddress "10.0.0.7" -ProviderAddress "192.168.4.22" -MACAddress "060600000007" -Rule "TranslationMethodEncap"  -CimSession $Hosts[$i]

    # Add the customer route records for Blue subnet 
    New-NetVirtualizationCustomerRoute -RoutingDomainID "{11111111-2222-3333-4444-000000005001}" -VirtualSubnetID "5001" -DestinationPrefix "10.0.0.0/24" -NextHop "0.0.0.0"  -Metric 255 -CimSession $Hosts[$i]

    #################################################################################################################
    # Red Virtual Network Information
    #
    # RoutingDomainID="{11111111-2222-3333-4444-000000006001}"
    # VirtualSubnetID=6001
    # (Both RDID and VSID are defined by administrators, MUST be unique in the datacenter)
    #
    # [Customer Addresses]
    # VM Name      Host    VSID  CA        PA             MAC                DefaultGW
    # -------------------------------------------------------------------------------------------
    # Red1         Host1   6001  10.0.0.5  192.168.4.11   08-08-00-00-00-05  10.0.0.1
    # Red2         Host2   6001  10.0.0.7  192.168.4.22   08-08-00-00-00-07  10.0.0.1
    #
    # [Customer Routes]
    # DestPrefix   NextHopGW  Note
    # ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    # 10.0.0.0/24  0.0.0.0    Onlink route for Red subnet

    # Add the locator records for Red subnet
    New-NetVirtualizationLookupRecord -VirtualSubnetID "6001" -CustomerAddress "10.0.0.5" -ProviderAddress "192.168.4.11" -MACAddress "080800000005" -Rule "TranslationMethodEncap"  -CimSession $Hosts[$i]
    New-NetVirtualizationLookupRecord -VirtualSubnetID "6001" -CustomerAddress "10.0.0.7" -ProviderAddress "192.168.4.22" -MACAddress "080800000007" -Rule "TranslationMethodEncap"  -CimSession $Hosts[$i]

    # Add the customer route records for Red subnet
    New-NetVirtualizationCustomerRoute -RoutingDomainID "{11111111-2222-3333-4444-000000006001}" -VirtualSubnetID "6001" -DestinationPrefix "10.0.0.0/24" -NextHop "0.0.0.0"  -Metric 255 -CimSession $Hosts[$i]

}

#
# [2] Configure the Host Provider Addresses and Routes required for this setup
#
# [Host PA Address & Route information required by the VM policy]
#
# Host    Hostname        {PA's}          {VM:VirtualSubnetID} ==> Set on the VMNetworkAdapter on eash host
# --------------------------------------------------------------------------------------------------------------------------
# Host1   example-host1  192.168.4.11    {Blue1:5001, Red1:6001}
# Host2   example-host2  192.168.4.22    {Blue2:5001, Red2:6001}

  $cred = Get-Credential $admin

  # [2-1] Host1
  #
  # (a) Configure Provider Address and Route:
  #     Get the interface, assign the PA and the default route
        Write-Host "Configuring PA's and VSID's on", $Hosts[0] -ForegroundColor Yellow
        $iface = Get-NetAdapter $WNVNIC -CimSession $Hosts[0]
        New-NetVirtualizationProviderAddress -InterfaceIndex $iface.InterfaceIndex -ProviderAddress "192.168.4.11" -PrefixLength 24 -CimSession $Hosts[0]
  # (b) Set VirtualSubnetID on the VM network port
        Invoke-Command -ComputerName $Hosts[0] -Credential $cred {
          Get-VMNetworkAdapter "Blue1" | where {$_.MacAddress -eq "060600000005"} | Set-VMNetworkAdapter -VirtualSubnetID 5001;
          Get-VMNetworkAdapter "Red1"  | where {$_.MacAddress -eq "080800000005"} | Set-VMNetworkAdapter -VirtualSubnetID 6001;
        }

  # [2-2] Host2
  #
  # (a) Configure Provider Address and Route:
  #     Get the interface, assign the PA and the default route
        Write-Host "Configuring PA's and VSID's on", $Hosts[1] -ForegroundColor Yellow
        $iface = Get-NetAdapter $WNVNIC -CimSession $Hosts[1]
        New-NetVirtualizationProviderAddress -InterfaceIndex $iface.InterfaceIndex -ProviderAddress "192.168.4.22" -PrefixLength 24 -CimSession $Hosts[1]
  # (b) Set VirtualSubnetID on the VM network port
        Invoke-Command -ComputerName $Hosts[1] -Credential $cred {
          Get-VMNetworkAdapter "Blue2" | where {$_.MacAddress -eq "060600000007"} | Set-VMNetworkAdapter -VirtualSubnetID 5001;
          Get-VMNetworkAdapter "Red2"  | where {$_.MacAddress -eq "080800000007"} | Set-VMNetworkAdapter -VirtualSubnetID 6001;
        }

