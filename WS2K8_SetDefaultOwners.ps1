import-module failoverclusters
$ClusterName = Read-Host " Input the cluster name (EG Cluster01.lab.local) "
$ClusterNodes = Get-ClusterNode -cluster $ClusterName

Function GetNumberFromId ([String]$id)
{
  $Split = $id  –Split  “-“
  $Lastsplit = $Split[-1]
  $LastSplitDecimal =  [int]$Lastsplit
  Return $LastSplitDecimal
}


foreach ($NodeName in $ClusterNodes) 
{
    $ID = Get-ClusterNode -Cluster $ClusterName -Name $NodeName | Select-Object id
    $VMs = Get-ClusterGroup -cluster $clusterName | Where-Object {-not ($_.IsCoreGroup) -and $_.DefaultOwner -EQ "4294967295" -and $_.OwnerNode -eq "$NodeName"}
    
    foreach ($VM in $VMs)
    {
    $VM.DefaultOwner= GetNumberFromID $ID
    }
}
Write-host "" -ForegroundColor Green
Write-host "" -ForegroundColor Green
Write-host "Showing Status" -ForegroundColor Green
Get-ClusterGroup -Cluster $ClusterName | Where-Object { -not ($_.IsCoreGroup) } | where-object {$_.DefaultOwner -NE "4294967295"}