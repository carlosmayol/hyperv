# 
Import-Module FailoverClusters

$objs = @()

$csvs = Get-ClusterSharedVolume 
$n = 1 
Echo "Cluster Shared Volumes mapped to Physical Disks" > C:\Windows\Cluster\Reports\CSVtoDiskMap.txt 
Echo =============================================== >> C:\Windows\Cluster\Reports\CSVtoDiskMap.txt 
Echo `n"Collecting cluster resource information..." 
foreach ( $csv in $csvs ) 
    { 
    Echo "Processing Cluster Shared Volume $n" 
    $Signature = ( $csv | Get-ClusterParameter DiskSignature ).Value.substring(2) 
        $obj = New-Object PSObject -Property @{ 
            Name          = $csv.Name 
            CSVPath       = ( $csv | select -Property Name -ExpandProperty SharedVolumeInfo).FriendlyVolumeName 
            PhysicalDisk  = ( Get-WmiObject Win32_DiskDrive | Where { "{0:x}" -f $_.Signature -eq $Signature } ).DeviceID.substring(4) 
        } 
    ($obj).PhysicalDisk = ($obj).PhysicalDisk -Replace "PHYSICALDRIVE", "Physical Disk " 
    $objs += $obj 
    $n++ 
    } 
Echo `n"Output file: C:\Windows\Cluster\Reports\CSVtoDiskMap.txt"`n 
$objs | FT Name, CSVPath, PhysicalDisk >> C:\Windows\Cluster\Reports\CSVtoDiskMap.txt 
notepad C:\Windows\Cluster\Reports\CSVtoDiskMap.txt
