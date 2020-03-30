# Script to determine the IC Version on the Hyper-V Host
# and output KVP Date of the running Guests
# rvi 1.0
# based on:
# http://blogs.msdn.com/b/virtual_pc_guy/archive/2008/11/18/hyper-v-script-looking-at-kvp-guestintrinsicexchangeitems.aspx
# and
# http://social.technet.microsoft.com/wiki/contents/articles/hyper-v-script-to-check-ic-version.aspx
# 

 
 
# Filter for parsing XML data
filter Import-CimXml 
{ 
   # Create new XML object from input
   $CimXml = [Xml]$_ 
   $CimObj = New-Object -TypeName System.Object 
 
   # Iterate over the data and pull out just the value name and data for each entry
   foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='Name']")) 
      { 
         $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE 
      } 
 
   foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='Data']")) 
      { 
         $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE 
      } 
 
   # Display output
   $CimObj 
} 
 
 
## Hostinfo this host
$Server="."
$Hostinfo = Get-WmiObject -class win32_computersystem -computername $Server
 
Write-Host "Host " $Hostinfo.Name
$HyperVServer = $Hostinfo.Name
 

# Get the host's ICversion
$icVersionHost = (ls 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization\GuestInstaller').`
    GetValue("Microsoft-Hyper-V-Guest-Installer-Win60-Package")
 
Write-Host "IC Version on Host" $icVersionHost
 

$vmList = gwmi -namespace root\virtualization Msvm_ComputerSystem |`
    where{$_.Name -ne $env:COMPUTERNAME}
    
foreach ($vminstance in $vmlist)
{
 
    if ($vminstance.OnTimeInMilliseconds -ne 0)
    {
    
 $VMName = $vminstance.ElementName
 
 # Get the virtual machine object
 $query = "Select * From Msvm_ComputerSystem Where ElementName='" + $VMName + "'"
 $Vm = gwmi -namespace root\virtualization -query $query -computername $HyperVServer
 
 # Get the KVP Object
 $query = "Associators of {$Vm} Where AssocClass=Msvm_SystemDevice ResultClass=Msvm_KvpExchangeComponent"
 $Kvp = gwmi -namespace root\virtualization -query $query -computername $HyperVServer
 
 Write-Host
 Write-Host "Guest KVP information for" $VMName
 
 # Filter the results
 $Kvp.GuestIntrinsicExchangeItems | Import-CimXml 
    }
}
 

#End of script
