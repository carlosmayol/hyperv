# Create resource pools
New-VMResourcePool -Name PrivateLocal -ResourcePoolType Ethernet -ComputerName ws2012clu-lab, ws2012clu-lab2
Add-VMSwitch -Name Private -ResourcePoolName PrivateLocal -ComputerName ws2012clu-lab, ws2012clu-lab2

# Remove resource pools
Remove-VMResourcePool -Name PrivateLocalMAD -ResourcePoolType Ethernet 
Remove-VMResourcePool -Name PrivateLocalBCN -ResourcePoolType Ethernet 

#Get Res Pools status
Get-VMresourcePool

# Set VM's to ResourcePool
Set-VMNetworkAdapter -VMName vmtest4 -Name "Network Adapter" -ResourcePoolName PrivateLocal
Connect-VMNetworkAdapter -name "Network Adapter" -VMName vmtest4 -UseAutomaticConnection

#Enable Metering
Enable-VMResourceMetering -ResourcePoolName Primordial -ResourcePoolType Ethernet
Enable-VMResourceMetering -ResourcePoolName PrivateLocal -ResourcePoolType Ethernet
Enable-VMResourceMetering -ResourcePoolName Primordial -ResourcePoolType VHD
Enable-VMResourceMetering -ResourcePoolName Primordial -ResourcePoolType Memory
Enable-VMResourceMetering -ResourcePoolName Primordial -ResourcePoolType Processor

#Get Metering enabled pools
Get-VMresourcePool | Where-Object {$_.ResourceMeteringEnabled}
Measure-VMResourcePool -Name Primordial | fl ResourcePoolName, MeteringDuration

#Show Meters for Resource pool
#Measure-VMResourcePool *
Measure-VMResourcePool Primordial
Measure-VMResourcePool PrivateLocal

#Show Meters for a VM 
Measure-VM -Name vmtest1

#Show Metering Network ACLs
Get-VMNetworkAdapterAcl -VMName vmtest1

#Show network meters details for a VM
$a = Measure-VM -Name vmtest1
$a.NetworkMeteredTrafficReport

#Reset Meters
Reset-VMResourceMetering *