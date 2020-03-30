#enum-vms.ps1
#Written by Ben Pearce
#This script enumerates all the guests on a host and returns the elementname and state of each VM
#How to use:
#
# .\enum-vms.ps1 -virtualhost localhost -sortbystate $true

param($virtualhost=”LocalHost”, [switch]$sortbystate)
$erroractionpreference = "SilentlyContinue"
$error.clear()

#Get all VMS from VirtualHost
$vms = Get-WmiObject -Class Msvm_ComputerSystem -Namespace "root\virtualization" -ComputerName $virtualhost

if ($error.count -eq 0)
{
	#This drops the host
	$vms = $vms | where-object{$_.caption -ne "Hosting Computer System"}
	
	#Sort array if selected by user
	if ($sortbystate)
	{
		$vms = $vms | Sort-Object -Property enabledstate
		
	}
	
	#Now loop through each VM and change the state to an understandable word
	foreach ($vm in $vms)
	{
		switch($vm.enabledstate)
		{
			0 {$state = "Unknown"}
			2 {$state = "Enabled"}
			3 {$state = "Disabled"}
			32768 {$state = "Paused"}
			32769 {$state = "Suspended"}
			32770 {$state = "Starting"}
			32771 {$state = "Snapshotting"}
			32772 {$state = "Migrating"}
			32773 {$state = "Saving"}
			32774 {$state = "Stopping"}
			32775 {$state = "Deleted"}
			32776 {$state = "Pausing"}
		}
		#Display Name and State on Screen
		$vm.elementname + $state
	}
}
else
{
	"`r"
	"Could not enumerate virtual host"
	$Error[0].exception.message
	"`r"
}
