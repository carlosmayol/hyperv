$vNIC = Get-VMNetworkAdapter -ManagementOS | Select Name,SwitchName,MacAddress,BandwidthPercentage,BandwidthSetting

$final = "" | select Name, SwitchName, MacAddress, BandwidthPercentage,BandwidthSetting
$final.Name = $vNIC.Name
$final.SwitchName = $vNIC.SwitchName
$final.MacAddress = $vNIC.MacAddress
$final.BandwidthSetting = $vNIC.BandwidthSetting.MinimumBandwidthWeight
$final.BandwidthPercentage = $vNIC.BandwidthPercentage
$final | ft -AutoSize
