# .DESCRIPTION
# This scripts creates Gen2 Differencial disk VMs for 2012R2 Update VHDX, 2GB startup with DM enabled.

<# To DOs -> 
Definir mas opciones, vm type, gen, mem, additional data disk etc


#>

# Defining parameters
$VMnum = read-host 'How many VMs do you want to create'
$VMNumber = [int]$VMnum
$StartNum = read-host 'Sequential VMTEST begins with #'
$StartNumber = [int]$StartNum
$VMName = Read-Host 'Define the name of your VM´s series'
$VMTotal = $vmnumber + $StartNumber
$VMTotalName = $VMNumber + $StartNumber -1


Write-Host "The VMs creation will go from $VMname$StartNumber to $VMname$VMTotalName"
Pause 
do {
    $vm = $VMname+$StartNumber
    New-VM -Name $vm -MemoryStartupBytes 2GB -Path F:\VMsHyperV\VMs -Generation 2 
    New-VHD -Differencing -Path F:\VMsHyperV\VMs\$vm.vhdx -SizeBytes 60GB -ParentPath 'C:\VMsHyperV\VM Library\win2012R2-BaseSysPrep_Update.vhdx' -OutVariable $null
    Connect-VMNetworkAdapter -VMName $vm -SwitchName Private
    Add-VMHardDiskDrive -VMName $vm -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path F:\VMsHyperV\VMs\$vm.vhdx
    Set-VMProcessor -CompatibilityForMigrationEnabled $false -VMName $vm -Count 2
    write-host "Creation of $VMname$StartNumber finished"
    write-host ""
    $StartNumber = $StartNumber+1

    }
until ($StartNumber -eq $VMTotal)

#Clear-Host
write-host ""
write-host ""
Write-Host "VM creation finished" -ForegroundColor Green
Get-VM $VMName* | ft name, pro*, mem*, gen*
