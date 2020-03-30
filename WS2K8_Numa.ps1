# Developer: Anthony F. Voellm
#          : Taylor Brown
# Copyright (c) 2008 by Microsoft Corporation
# All rights reserved
#
# This is "demonstration" code and there are no
# warrantees expressed or implied
################################################
 
 
 
# This script will set the Virtual Machine to run
# on a specific NUMA node
 
 
 
# Check command line arguments
 
if (($args.length -lt 1) -or
    (($args[0] -ne "/list") -and
     ($args[0] -ne "/set") -and
     ($args[0] -ne "/clear")) -or
     (($args[0] -eq "/set") -and ($args.length -lt 3)) -or 
     (($args[0] -eq "/clear") -and ($args.length -lt 2))) {
     Write-Host "numa.ps1 /list [<Hyper-V host>]"
     Write-Host "numa.ps1 /set <vm machine name> <required node> [<Hyper-V host>]"
     Write-Host "numa.ps1 /clear <vm machine name> [<Hyper-V host>]`n"
     Write-Host "Options:"
     Write-Host "`t/list - show configured VM's"
     Write-Host "`t/set <vm machine name> <required node> - set the NUMA node for the VM"
     Write-Host "`t/clear <vm machine name> - clear NUMA node seting for the VM"
     exit;
  }
 
 
 
# just display VM's
if ($args[0] -eq "/list") {
  if ($args.length -gt 1) {
    $HyperVHost = $args[1];
  }
  Get-WmiObject -Namespace 'root\virtualization' -Query "Select * From Msvm_ComputerSystem" | select ElementName
  exit;
}
 
 
 
# Set or clear 

$HyperVHost = '.';
if ($args[0] -eq "/set") {
  if ($args.length -gt 3) {
    $HyperVHost = $args[3];
  }
  $VMName = $args[1];
  $RequiredNode = $args[2];
} elseif ($args[0] -eq "/clear") {
  if ($args.length -gt 2) {
    $HyperVHost = $args[2];
  }
  $VMName = $args[1];
}
 
  
#Main Script Body 
$VMManagementService = Get-WmiObject -Namespace root\virtualization -Class Msvm_VirtualSystemManagementService -ComputerName $HyperVHost
 

$Query = "Select * From Msvm_ComputerSystem Where ElementName='" + $VMName + "'"
 
 
$SourceVm = Get-WmiObject -Namespace root\virtualization -Query $Query -ComputerName $HyperVHost 

 
 
$VMSettingData = Get-WmiObject -Namespace root\virtualization -Query "Associators of {$SourceVm} Where ResultClass=Msvm_VirtualSystemSettingData AssocClass=Msvm_SettingsDefineState" -ComputerName $HyperVHost 

 
 
if ($args[0] -eq "/set") {
  $VMSettingData.NumaNodesAreRequired = 1
  $VMSettingData.NumaNodeList = @($RequiredNode)
} else {
  $VMSettingData.NumaNodesAreRequired = 0
}
 
 
 
$VMManagementService.ModifyVirtualSystem($SourceVm, $VMSettingData.PSBase.GetText(1)) 
