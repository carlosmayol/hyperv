# Function for handling WMI jobs / return values
Function ProcessResult($result, $successString, $failureString)
{
   #Return success if the return value is "0"
   if ($result.ReturnValue -eq 0)
      {write-host $successString} 
 
   #If the return value is not "0" or "4096" then the operation failed
   ElseIf ($result.ReturnValue -ne 4096)
      {write-host $failureString "  Error value:" $result.ReturnValue}
 
   Else
      {#Get the job object
      $job=[WMI]$result.job
 
      #Provide updates if the jobstate is "3" (starting) or "4" (running)
      while ($job.JobState -eq 3 -or $job.JobState -eq 4)
         {write-host $job.PercentComplete "% complete"
          start-sleep 1
 
          #Refresh the job object
          $job=[WMI]$result.job}
 
       #A jobstate of "7" means success
       if ($job.JobState -eq 7)
          {write-host $successString}
       Else
          {write-host $failureString
          write-host "ErrorCode:" $job.ErrorCode
          write-host "ErrorDescription" $job.ErrorDescription}
       }
}
 
# Prompt for the Hyper-V Server to use
$HyperVServer = Read-Host "Specify the Hyper-V Server to use (enter '.' for the local computer)"

# Prompt for the new CPU reservation
$NewReservation = Read-Host "Specify the CPU reservation (from 0-10000)"
 
# Get the management service
$VMMS = gwmi -namespace root\virtualization Msvm_VirtualSystemManagementService -computername $HyperVServer
 
# Get all VSSDs for non-snapshots
$VSSDs = gwmi "MSVM_VirtualSystemSettingData" -namespace "root\virtualization" -computername $HyperVServer | ? {$_.SettingType -eq 3}  
 
foreach ($VSSD in $VSSDs)
   {
   # Get the related VM
   $VM = $VSSD.getRelated("MSVM_ComputerSystem") | select -first 1
   
   # Get the processor setting data
   $ProcSetting = $VSSD.getRelated("Msvm_ProcessorSettingData") | select -first 1

   # Update ProcSetting with the new value
   $ProcSetting.Reservation = $NewReservation
 
   # Apply the changes to the processor setting data back to the virtual machine
   $result = $VMMS.ModifyVirtualSystemResources($VM, $ProcSetting.GetText(1))
  
   # Process the result
   $successMessage = "Updated processor scheduling settings on '" + $VM.ElementName + "'"
   $failureMessage = "Failed to update processor scheduling settings on " + $VM.ElementName + "'"
   ProcessResult $result $successMessage $failureMessage
   }