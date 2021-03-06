# ExportVMConfig.ps1 
# Usage: ./ExportVMConfig.ps1 <VMName> <Path to store export dir> 
# Example: ./ExportVMConfig.ps1 "Test" "d:\vmexports"

param([parameter(Mandatory=$TRUE,ValueFromPipeline=$TRUE)] $VMName, [parameter(Mandatory=$TRUE,ValueFromPipeline=$TRUE)] $expDir) 
  
# Get VM, VMMS  & Export Settings Objects

$ns = 'root\virtualization' 
$vmms = gwmi -n $ns Msvm_VirtualSystemManagementService 
$vm = gwmi -n $ns Msvm_ComputerSystem | ?{$_.ElementName -eq $VMName} 
$exp = @($vm.GetRelated('Msvm_VirtualSystemExportSettingData'))[0] 
  
# Don't Export VHDs & saved state data. Create a folder for VM's export data 
  
$exp.CopyVmStorage = $false 
$exp.CopyVmRuntimeInformation = $false 
$exp.CreateVmExportSubdirectory = $true

#Perform Export 
  
$out = $vmms.ExportVirtualSystemEx($vm.Path.Path, $expDir, $exp.GetText(1)) 
  
#Perform Job handling if necessary 
  
if ($out.ReturnValue -eq 4096){ 
    $task = [Wmi]$out.Job; 
    while($task.JobState -eq 3 -or $task.JobState -eq 4){ 
        $task.Get(); 
        sleep 1; 
        } 
    if ($task.JobState -ne 7){ 
        "Error exporting VM " + $task.ErrorDescription; 
        }             
    else { 
        "Export completed successfully..." 
        } 
    } 
elseif ($out.ReturnValue -ne 0) { 
    "Export failed with error : " + $out.ReturnValue; 
    } 
else { 
    "Export completed successfully..." 
    }