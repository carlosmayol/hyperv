
# the following PowerShell sample script enables communication with specific IP Address:

$VMName = Read-host 'Introduce VM Name'
$AllowIPv4 = Read-Host 'Introduce Specific IPv4 in format: X.X.X.X'
#$VmName = "TestVM"
$Msvm_ComputerSystem = (Get-WmiObject -Namespace root\virtualization `
  -Class Msvm_ComputerSystem -Filter "ElementName='$VmName'")
 
#Retrieve all Msvm_SyntheticEthernetPort's associated with this VM 
#  there will be one per Synthetic NIC
$Msvm_SyntheticEthernetPortCollection = `
 $Msvm_ComputerSystem.GetRelated("Msvm_SyntheticEthernetPort")
#This will get the last object in a collection or if the collection 
#  has one object just that object
$Msvm_SyntheticEthernetPort = $Msvm_SyntheticEthernetPortCollection | % {$_}
 
#There will only ever be one Msvm_VmLANEndpoint per 
#  Msvm_SyntheticEthernetPort
$Msvm_VmLANEndpointCollection = `
 $Msvm_SyntheticEthernetPort.GetRelated("Msvm_VmLANEndpoint")
$Msvm_VmLANEndpoint = $Msvm_VmLANEndpointCollection | % {$_}
 
#There will only ever be one Msvm_SwitchPort per Msvm_VmLANEndpoint
$Msvm_SwitchPortCollection = ` 
 $Msvm_VmLANEndpoint.GetRelated("Msvm_SwitchPort")
#This will get the last object in a collection or if the collection
#   has one object just that object
$Msvm_SwitchPort = $Msvm_SwitchPortCollection | % {$_}
 
$Msvm_SwitchPort.PreventIPSpoofing=$true
#$Msvm_SwitchPort.AllowedIPv4Addresses= (, "192.168.0.1")
$Msvm_SwitchPort.AllowedIPv4Addresses=$AllowIpv4
$Msvm_SwitchPort.Put()




