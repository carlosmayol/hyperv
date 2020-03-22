$Path = read-host " Introduce full path for VHD / VHDX"
#if (Test-Path $Path)
#   {
    Echo "Attempting to Mount $Path" 
    Mount-vhd -path $Path -readonly 
    Echo "Attempting to compact $Path" 
    Optimize-vhd -path $Path -Mode Full
    Echo "Attempting to dismount $Path" 
    Dismount-vhd -path $Path
#   }
#Else {Write-Host "`t`The path is not correct" -ForegroundColor Yellow}
