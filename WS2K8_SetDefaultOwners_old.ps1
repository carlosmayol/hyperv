import-module failoverclusters
$VMs = Get-ClusterGroup -Cluster PutClusterName | Where-Object {$_.IsCoreGroup -NE "True"}
foreach ($VM in $VMs){
$VM.DefaultOwner=1
}
Write-host "" -ForegroundColor Green
Write-host "" -ForegroundColor Green
Write-host "Showing Status" -ForegroundColor Green
Get-ClusterGroup -Cluster PutClusterName | Where-Object { -not ($_.IsCoreGroup) } | where-object {$_.DefaultOwner -NE "1"}