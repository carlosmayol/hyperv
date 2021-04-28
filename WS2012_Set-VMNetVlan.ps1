#Setting stuff

get-vm * | ? State -eq running | Get-VMNetworkAdapter | ? {$_.IPAddresses -match "192.168.180.*"} | Set-VMNetworkAdapter -DeviceNaming On -Passthru | Rename-VMNetworkAdapter -NewName 'Domain'

get-vm * | ? State -eq running | Get-VMNetworkAdapter | ? {$_.IPAddresses -match "192.168.230.*"} | Set-VMNetworkAdapter -DeviceNaming On -Passthru | Rename-VMNetworkAdapter -NewName 'iSCSI'
Get-VMNetworkAdapter -VMName * -Name iSCSI | Set-VMNetworkAdapterVlan -VlanId 30 -Access

get-vm * | ? State -eq running | Get-VMNetworkAdapter | ? {!($_.IPAddresses)} | Set-VMNetworkAdapter -DeviceNaming On -Passthru | Rename-VMNetworkAdapter -NewName 'pNIC'
Get-VMNetworkAdapter -VMName * -Name pNIC | Set-VMNetworkAdapterVlan -Trunk -AllowedVlanIdList "10,20,30,40" -NativeVlanId 0
#Get-VMNetworkAdapter -VMName * -Name pNIC | Set-VMNetworkAdapterVlan -Untagged


get-vm * | ? State -eq running | Get-VMNetworkAdapter | ? {$_.IPAddresses -match "169.*"} | Set-VMNetworkAdapter -DeviceNaming On -Passthru | Rename-VMNetworkAdapter -NewName 'pNIC'
get-vm * | ? State -eq running | Get-VMNetworkAdapter | ? {$_.IPAddresses -match "169.*"} | Set-VMNetworkAdapterVlan -Trunk -AllowedVlanIdList "10,20,30,40" -NativeVlanId 0


#Showing Stuff
get-vm * | ? State -eq running | Get-VMNetworkAdapter

get-vm * | ? State -eq running | Get-VMNetworkAdapterVlan


