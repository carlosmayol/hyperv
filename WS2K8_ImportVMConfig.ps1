# ImportMConfig.ps1 
# Usage: ./ImportVMConfig.ps1 <VMName> <Path to export dir> <path to place VM Configuration Files> 
# Example: ./ImportVMConfig.ps1 "Test" "d:\vmexports" "D:\VirtualMachines"

param([parameter(Mandatory=$TRUE,ValueFromPipeline=$TRUE)] $VMName, [parameter(Mandatory=$TRUE,ValueFromPipeline=$TRUE)] $expDir, [parameter(Mandatory=$TRUE,ValueFromPipeline=$TRUE)] $VMdestdir)

# Copy export data from export dir to the path where VM's files will reside, and perform the import from there 

Copy-Item $expdir"\"$VMName -Destination $VMdestdir -recurse -ea "silentlycontinue" 
  
# Get VM, VMMS  & Export Settings Objects

$ns = 'root\virtualization' 
$vmms = gwmi -n $ns Msvm_VirtualSystemManagementService 
$SettingData = $vmms.GetVirtualSystemImportSettingData($VMdestdir+"\"+$VMName).ImportSettingData

# Do not try to copy de VHDs, as we didn't exported them

$SettingData.CreateCopy = $False

# Copy CurrentResourcePaths to SourceResourcePaths, as we assume paths has not changed

$SettingData.SourceResourcePaths = $SettingData.CurrentResourcePaths

# Do the Import VM config Only

$out=$vmms.importVirtualSystemEx($VMdestdir+"\"+$VMName, $SettingData.PSBase.GetText("CimDtd20") ) 

#Perform Job handling if necessary 
  
if ($out.ReturnValue -eq 4096){ 
    $task = [Wmi]$out.Job; 
    while($task.JobState -eq 3 -or $task.JobState -eq 4){ 
        $task.Get(); 
        sleep 1; 
        } 
    if ($task.JobState -ne 7){ 
        "Error Importing VM " + $task.ErrorDescription; 
        }             
    else { 
        "Import completed successfully..." 
        } 
    } 
elseif ($out.ReturnValue -ne 0) { 
    "Import failed with error : " + $out.ReturnValue; 
    } 
else { 
    "Import completed successfully..." 
    }