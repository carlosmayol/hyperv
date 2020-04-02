# previous saved logs, filter starting at 11/1/2013 at 18:40:00.
# to force network disconnection and connection

Get-VMNetworkAdapter -VMName lab1_clu2k8* | Disconnect-VMNetworkAdapter
Get-Date
Get-VMNetworkAdapter -VMName lab1_clu2k8*
Get-VMNetworkAdapter -VMName lab1_clu2k8* | Connect-VMNetworkAdapter -SwitchName External
Get-VMNetworkAdapter -VMName lab1_clu2k8*
Get-Date
