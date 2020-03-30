$query = "SELECT * FROM Win32_NetworkAdapter WHERE Manufacturer != 'Microsoft' AND NOT PNPDeviceID LIKE 'ROOT\\%'"
$NICS= Get-WmiObject -Query $query | Select name,DeviceId
$OSversion = Get-WmiObject -Class Win32_OperatingSystem | select name,version
$ChimneyOver10= ((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\services\VMSMP\Parameters" | get-itemproperty ) | select TenGigVmChimneyEnabled -ErrorAction SilentlyContinue)
$ChimneyBelow10= ((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\services\VMSMP\Parameters" | get-itemproperty ) | select BelowTenGigVmChimneyEnabled -ErrorAction SilentlyContinue)
$VMQover10 = ((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\services\VMSMP\Parameters" | get-itemproperty ) | select TenGigVmqEnabled -ErrorAction SilentlyContinue)
$VMQbelow10 = ((Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\services\VMSMP\Parameters" | get-itemproperty ) | select BelowTenGigVmqEnabled -ErrorAction SilentlyContinue)

Write-Host "OS Version: " $OSversion.name

foreach ($adapater in $NICS)
{
Write-Host $adapater.name
$erroractionpreference = "SilentlyContinue"
if ([Decimal]$adapater.DeviceId -cgt 9)
{
	$regpath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\00"+$adapater.deviceId
}
else
{
	$regpath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\000"+$adapater.deviceId
}
Write-Host $regpath

Get-ItemProperty -path $regpath | fl *TCP*,*jumbo*,*Lso*,*RSS*,*UDP*,*VMQ*

}


Write-Host "--------------Chimney Config------------------"

if ($ChimneyBelow10.BelowTenGigVmChimneyEnabled -ge 0)
{	
	Write-Host "BelowTenGigVmChimney = " $ChimneyBelow10.BelowTenGigVmChimneyEnabled
}
else
{
	
	Write-Host "BelowTenGigVmChimneyEnabled Registry key does not exist and is disabled"
}
if ($ChimneyOver10.TenGigVmChimneyEnabled -ge 0)
{	
	Write-Host "TenGigVmChimneyEnabled = " $ChimneyOver10.TenGigVmChimneyEnabled
}
else
{	
	Write-Host "TenGigVmChimneyEnabled Registry key does not exist and is disabled"
}

Write-Host "-----------------VMQ Config------------------"

if ($VMQBelow10.BelowTenGigVmqEnabled -ge 0)
{	
	Write-Host "BelowTenGigVmqEnabled = " $VMQBelow10.BelowTenGigVmqEnabled
}
else
{
	
	Write-Host "BelowTenGigVmqEnabled Registry key does not exist and is disabled"
}
if ($VMQOver10.TenGigVmqEnabled -ge 0)
{	
	Write-Host "TenGigVmqEnabled = " $VMQOver10.TenGigVmqEnabled
}
else
{	
	Write-Host "TenGigVmqEnabled Registry key does not exist and is disabled"
}
Invoke-Expression "netsh int tcp show global"

