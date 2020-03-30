import-module failoverclusters
Write-host "" -ForegroundColor Green
Write-host "" -ForegroundColor Green
Write-host "Showing Status" -ForegroundColor Green
Get-ClusterGroup -Cluster axinlabhvcls| Where-Object {$_.IsCoreGroup -NE "True"} | where-object {$_.DefaultOwner -EQ "4294967295"} | FL Name, defaultOwner
