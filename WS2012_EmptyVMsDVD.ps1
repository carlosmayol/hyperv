# Get-VMDvdDrive -VMName *
Set-VMDvdDrive  -vmname * -ControllerNumber 0 -ControllerLocation 1 -Path $null
Get-VMDvdDrive -VMName *