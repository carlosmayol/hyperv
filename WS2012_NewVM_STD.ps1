$VMnum = read-host 'How many VMs do you want to create'
$VMNumber = [int]$VMnum
$StartNum = read-host 'Sequential VMTEST begins with #'
$StartNumber = [int]$StartNum
$VMTotal = $vmnumber + $StartNumber
$VMTotalName = $VMNumber + $StartNumber -1


Write-Host "The VMs creation will go from VMTEST$StartNumber to VMTEST$VMTotalName"
Pause 
do {
    $vm = 'VMTEST'+$StartNumber
    New-VM -Name $vm -MemoryStartupBytes 512MB -Path C:\LocalVMsW8\
    New-VHD -Dynamic -Path C:\LocalVMsW8\$vm\$vm.vhdx -SizeBytes 20GB
    Connect-VMNetworkAdapter -VMName $vm -SwitchName Private
    Add-VMHardDiskDrive -VMName $vm -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Path C:\LocalVMsW8\$vm\$vm.vhdx
    Set-VMProcessor -CompatibilityForMigrationEnabled $true -VMName $vm
    write-host "Creation of VMTEST$StartNumber finished"
    $StartNumber = $StartNumber+1
    }
until ($StartNumber -eq $VMTotal)
Clear-Host
Write-Host "VM creation finished" -ForegroundColor Green