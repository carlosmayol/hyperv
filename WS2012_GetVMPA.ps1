<#
.SYNOPSIS
Generate a list of VMs and their corresponding Provider Addresses


.DESCRIPTION
Generate a list of VMs and their corresponding Provider Addresses


.INPUTS
A VMName or none (for all VMs on the host)

.OUTPUTS
List of VMs, MAC addresses, and Provider Addresses

.NOTES
Requires Windows Server 2012.

#>

param( 
    [Parameter(Position = 0, ParameterSetName="VMName",Mandatory=$False)][string]$VMName
)

function CreateVMObject()
{
  $IndResult=New-Object System.Object
  $IndResult | Add-Member -MemberType NoteProperty -Name "VMName"           -Value ""
  $IndResult | Add-Member -MemberType NoteProperty -Name "MACAddress"       -Value ""
  $IndResult | Add-Member -MemberType NoteProperty -Name "VirtualSubnetID"  -Value "0"
  $IndResult | Add-Member -MemberType NoteProperty -Name "CustomerAddress"  -Value ""
  $IndResult | Add-Member -MemberType NoteProperty -Name "ProviderAddress"  -Value ""
  $IndResult | Add-Member -MemberType NoteProperty -Name "PAInterfaceIndex" -Value "0"

  Return $IndResult
}

$VMList=@()
$VMObjArray=@()

if ($VMName) {
  #Write-Host "VMname is " $VMname
  $vm = Get-VM $VMname
  $VMList=($vm)
} else {
  #Write-Host "No VMName is given."
  $VMList = Get-VM
}

foreach ($v in $VMlist) {
  #Write-Host "[VM] " $v.Name
  $vNICs = Get-VMNetworkAdapter $v
  foreach ($n in $vNICs){
    #Write-Host "  o MAC Address = " $n.MACAddress
	if ($n.VirtualSubnetID){
	  $vobj = CreateVMObject
	  $vobj.VMName = $v.Name
	  $vobj.MACAddress = $n.MACAddress
	  $vobj.VirtualSubnetID = $n.VirtualSubnetID
	  #Write-Host "  o VirtualSubnetID = " $n.VirtualSubnetID
      $L = Get-NetVirtualizationLookupRecord -MACAddress $n.MACAddress
	  # Check if missing Lookup Record
      foreach ($l in $L){
        $p = $L.ProviderAddress
		$vobj.ProviderAddress = $p
		$vobj.CustomerAddress = $L.CustomerAddress
        #Write-Host "  o Provider Address =" $p
		$PA = Get-NetVirtualizationProviderAddress -ProviderAddress $p
		if($PA){
          #Write-Host "  o Interface: " $PA.InterfaceIndex
		  $vobj.PAInterfaceIndex = $PA.InterfaceIndex
		}else{
		  #Write-Host "  * ProviderAddress $p is missing"
		}
		$VMObjArray = $VMObjArray + $vobj
      }
    }else{
	  Write-Host "  o This vNIC is NOT Network Virtualized"
	}
  }
}

#Write-Host "Result = " 

$VMObjArray | Format-Table @{Expression={$_.VMName};Label="VM Name"},
  @{Expression={$_.MACAddress};       Label="MAC Address"},
  @{Expression={$_.VirtualSubnetID};  Label="VirtualSubnetID"},
  @{Expression={$_.CustomerAddress};  Label="CustomerAddress"},
  @{Expression={$_.ProviderAddress};  Label="ProviderAddress"},
  @{Expression={$_.PAInterfaceIndex}; Label="Iface Index"}


$VMobjArray.Clear()
