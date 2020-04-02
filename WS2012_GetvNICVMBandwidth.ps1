
<#get-vm | Get-VMNetworkAdapter | ft name, *band* -AutoSize
get-vm | Get-VMNetworkAdapter | select  -ExpandProperty BandwidthSetting
$a | ft -AutoSize

#>

$VMs = Get-VM

$result = @()

foreach ($vm in $VMs) {


$VMName  = $vm | Select Name

$vmNIC = $vm | Get-VMNetworkAdapter | Select SwitchName,MacAddress,BandwidthPercentage,BandwidthSetting

$final = "" | select Name, SwitchName, MacAddress, BandwidthPercentage,BandwidthSetting
$final.Name = $VMName.Name
$final.SwitchName = $vmNIC.SwitchName
$final.MacAddress = $vmNIC.MacAddress
$final.BandwidthSetting = $vmNIC.BandwidthSetting.MinimumBandwidthWeight
$final.BandwidthPercentage = $vmNIC.BandwidthPercentage

# Adding current array to a hash array, so I can better manipulate the output
$result += $final

}

$result | ft -AutoSize