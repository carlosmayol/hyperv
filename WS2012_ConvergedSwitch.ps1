New-NetLbfoTeam "TEAM1" –TeamMembers "Ethernet","Ethernet 2" -TeamNicName "TEAM1" -LoadBalancingAlgorithm HyperVPort -TeamingMode SwitchIndependent

New-VMSwitch 'ConvergedvSwitch' -MinimumBandwidthMode weight -NetAdapterName 'TEAM1' -AllowManagementOS 1

Add-VMNetworkAdapter -ManagementOS -Name 'TEAM1 - LM VLAN 20' -SwitchName 'ConvergedvSwitch'
Add-VMNetworkAdapter -ManagementOS -Name 'TEAM1 - Cluster VLAN 10' -SwitchName 'ConvergedvSwitch'

sleep 5
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName 'TEAM1 - LM VLAN 20' -Access -VlanId 20
#Set to Untagged
#Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName 'TEAM1 - LM VLAN 20' -Untagged

Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName 'TEAM1 - Cluster VLAN 10' -Access -VlanId 10
#Set to Untagged
#Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName 'TEAM1 - Cluster VLAN 10' -Untagged

#Set Bandwidth

Set-VMNetworkAdapter -ManagementOS -Name 'ConvergedvSwitch' -MinimumBandwidthWeight 20

Set-VMNetworkAdapter -ManagementOS -Name 'TEAM1 - Cluster VLAN 10' -MinimumBandwidthWeight 20

Set-VMNetworkAdapter -ManagementOS -Name 'TEAM1 - LM VLAN 20' -MinimumBandwidthWeight 40

Set-VMSwitch 'ConvergedvSwitch' -DefaultFlowMinimumBandwidthWeight 20

#Get-VMNetworkAdapter -ManagementOS  | fl Name, BandwidthPercentage

#Set IPs

sleep 15
Set-NetIPInterface -InterfaceAlias 'vEthernet (ConvergedvSwitch)' -dhcp Enabled
Set-NetIPInterface -InterfaceAlias 'vEthernet (ConvergedvSwitch)' -dhcp Disabled; New-NetIPAddress -PrefixLength 24 -InterfaceAlias 'vEthernet (ConvergedvSwitch)' -IPAddress 192.168.180.3 -DefaultGateway 192.168.180.254
Set-DnsClientServerAddress -InterfaceAlias 'vEthernet (ConvergedvSwitch)' -ServerAddresses 192.168.180.9

sleep 15

Set-NetIPInterface -InterfaceAlias 'vEthernet (TEAM1 - Cluster VLAN 10)' -dhcp Disabled; New-NetIPAddress -PrefixLength 24 -InterfaceAlias 'vEthernet (TEAM1 - Cluster VLAN 10)' -IPAddress 192.168.210.1
Set-NetIPInterface -InterfaceAlias 'vEthernet (TEAM1 - LM VLAN 20)' -dhcp Disabled; New-NetIPAddress -PrefixLength 24 -InterfaceAlias 'vEthernet (TEAM1 - LM VLAN 20)' -IPAddress 192.168.220.1

#Show operation result
Get-VMNetworkAdapter -ManagementOS  | fl Name, BandwidthPercentage
Get-NetIPAddress | where-object {$_.InterfaceAlias -match "vEth*"} | sort InterfaceAlias | FT InterfaceAlias, IPAddress
Get-VMNetworkAdapterVlan