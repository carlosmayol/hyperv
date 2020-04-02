$VMNames=5..6 | % {"LAB6_WS2019_0$_"}
11..20 | Foreach-Object {
    $DiskPathp1 = "V:\VMsHyperV\VMs\Virtual Hard Disks\"
    $DiskPathp2 = $vmnames[0]
    $DiskPathp3 = "_d$_.vhdx"
    $DiskPath = $DiskPathp1, $DiskPathp2, $DiskPathp3 -join ""
    
    $DiskPath1p1 = "V:\VMsHyperV\VMs\Virtual Hard Disks\"
    $DiskPath1p2 = $vmnames[1]
    $DiskPath1p3 = "_d$_.vhdx"
    $DiskPath1 = $DiskPath1p1, $DiskPath1p2, $DiskPath1p3 -join ""

    #write-host "$DiskPath $DiskPath1"

    New-VHD -Path $DiskPath -SizeBytes 10GB -Dynamic
    New-VHD -Path $DiskPath1 -SizeBytes 10GB -Dynamic
    Add-VMHardDiskDrive -VMName $vmnames[0] -Path $DiskPath
    Add-VMHardDiskDrive -VMName $vmnames[1] -Path $DiskPath1
}

