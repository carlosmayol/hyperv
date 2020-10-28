foreach ($vm in (get-vm | Where-Object {$_.State -eq "off" }))
    {
        $disks = $vm | Get-VMHardDiskDrive | Select-Object -ExpandProperty Path
        
        foreach ($disk in $disks) {
           if (Test-Path $disk)
           {
            Write-Host "Attempting to Mount $disk" -ForegroundColor Green
            Mount-vhd -path $disk -readonly 
            Write-Host "Attempting to compact $disk" -ForegroundColor Yellow
            Optimize-vhd -path $disk -Mode Full -Verbose
            Write-Host "Attempting to dismount $disk" -ForegroundColor Green
            Dismount-vhd -path $disk
           }
            Else {Write-Host "`t`The path is not correct" -ForegroundColor Yellow}
           }
    }