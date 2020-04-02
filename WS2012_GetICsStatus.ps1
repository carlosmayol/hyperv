# GetSummaryInformation documented here: http://msdn.microsoft.com/en-us/library/hh850062(v=vs.85).aspx
# MSVM_SummaryInformation documented here: http://msdn.microsoft.com/en-us/library/hh850217(v=vs.85).aspx
 
# Get the Management Service from the v2 namespace
$VMMS = gwmi -namespace root\virtualization\v2 Msvm_VirtualSystemManagementService
 
# 1 == VM friendly name. 123 == Integration State
$RequestedSummaryInformationArray = 1,123
$vmSummaryInformationArray = $VMMS.GetSummaryInformation($null, $RequestedSummaryInformationArray).SummaryInformation
 
# Create an empty array to store the results in
$outputArray = @()
 
# Go over the results of the GetSummaryInformation Call
foreach ($vmSummaryInformation in [array] $vmSummaryInformationArray)
   {  
 
   # Turn result codes into readable English
   switch ($vmSummaryInformation.IntegrationServicesVersionState)
      {
       1       {$vmIntegrationServicesVersionState = "Up-to-date"}
       2       {$vmIntegrationServicesVersionState = "Version Mismatch"}
       default {$vmIntegrationServicesVersionState = "Unknown"}
      }
 
   # Use Hyper-V PowerShell cmdlets to quickly get the integration version number
   $vmIntegrationServicesVersion = (get-vm $vmSummaryInformation.ElementName).IntegrationServicesVersion
   # Display "Unknown" if we got a null result
   if ($vmIntegrationServicesVersion -eq $null) {$vmIntegrationServicesVersion = "Unknown"}
 
   # Put the VM Name, Integration Service Version and State in a PSObject - so we can display a nice table at the end
   $output = new-object psobject
   $output | add-member noteproperty "VM Name" $vmSummaryInformation.ElementName
   $output | add-member noteproperty "Integration Services Version" $vmIntegrationServicesVersion
   $output | add-member noteproperty "Integration Services State" $vmIntegrationServicesVersionState
 
   # Add the PSObject to the output Array
   $outputArray += $output
 
   }
 
# Display information in nicely formatted table
write-output $outputArray | sort "VM Name"