#Requires -version 3
#Requires -runasadministrator

$h = $null
$h = @()
$result = $null
$result = @()


foreach ($vm in (get-vm))
    {
        $diskcount = $null
        $disks = $vm | Get-VMHardDiskDrive | ForEach-Object{get-vhd -path $_.Path} | Select-Object Path,Size,FileSize,ParentPath,DiskIdentifier
        if ($disks.count -eq $null)  {$diskcount = 1}
            else {$diskcount = $disks.count}

        foreach ($disk in $disks) 
            {
            $h = New-Object System.Object
            $h | Add-Member -Type NoteProperty -name "VMname" -Value $vm.Name
            $h | Add-Member -type NoteProperty -name "DiskCount" -value $diskcount
            $h | Add-Member -type NoteProperty -name "Path" -value $disk.path
            $h | Add-Member -type NoteProperty -name "Size" -value $disk.Size
            $h | Add-Member -type NoteProperty -name "FileSize" -value $disk.FileSize
            $h | Add-Member -type NoteProperty -name "ParentPath" -value $disk.ParentPath
            $h | Add-Member -type NoteProperty -name "DiskIdentifier" -value $disk.DiskIdentifier

            $result += $h
            }
    }


$result | Format-Table  VMName,Diskcount,Path,@{Expression={$_.Size/1GB};Label="Size"},@{Expression={"{0:N1}"-f ($_.Filesize/1GB)};Label="FileSize"},ParentPath,DiskIdentifier -AutoSize



