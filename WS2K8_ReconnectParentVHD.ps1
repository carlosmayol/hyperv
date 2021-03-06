# You can also use  Connect-VHDParent cmdLet from HyperV Tools (Codeplex)

param(
    [string] $childPath  = $(throw "Must supply a child path"),
    [string] $parentPath = $(throw "Must supply a parent path"),
    [string] $computer = "."
)

$ns = "root\virtualization"

# get the Msvm_ImageManagementService
$imageService = gwmi -Namespace $ns -ComputerName $computer Msvm_ImageManagementService

# call reconnect
$result = $imageService.ReconnectParentVirtualHardDisk($childPath, $parentPath, $true)
$ret = $result.ReturnValue

# handle the return parameter
if ($ret -eq 0)
{
   "success"
}
elseif ($ret -eq 4096)
{
   $job = [wmi]$result.Job
   
   while ($job.jobstate -lt 7) {$job.Get()}
   
   if ($job.JobState -eq 7)
   {
      "success"
   }
   else
   {
      # job failed. Return its error code and description.
      $job.ErrorCode
      $job.ErrorDescription
   }
}
else
{
   # method failed. Return the failure code. 
   $ret
}
