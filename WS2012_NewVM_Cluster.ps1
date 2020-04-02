#New VM
$vm = 'VMTEST5Clustered'
New-VM -Name $vm -MemoryStartupBytes 512MB -Path W:\ClusterStorage\Volume1\
New-VHD -Dynamic -Path W:\ClusterStorage\Volume1\$vm\$vm.vhdx -SizeBytes 20GB
Connect-VMNetworkAdapter -VMName $vm -SwitchName Private
Add-VMHardDiskDrive -VMName $vm -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Path W:\ClusterStorage\Volume1\$vm\$vm.vhdx
Set-VMProcessor -CompatibilityForMigrationEnabled $true -VMName $vm

## Make it Cluster Resource
Add-VMToCluster -VMName $vm 

#Revome it from cluster
#Remove-VMFromCluster -Name $vm -RemoveResources -Force 