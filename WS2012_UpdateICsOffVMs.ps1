# Este script solo funciciona con VMs 2008/Vista o superior. Valido solo para VMs Generation 1
# Este script debe ejecutarse en el HOST de Hyper-V de forma local.
#      La version Windows6.x-HyperVIntegrationServices-x64.cab es compatible con Win2008/vista/2008R2/W7
#      La version Windows6.2-HyperVIntegrationServices-x64.cab es compatible con Win2012 y superior
# 
# v1, esta version requiere deteccion de la version del OS para seleccionar el IC apropiado
#     Opcion para los VM que están "Sttoped"
#     
#     PTE - Convertir en Script para version offline (plantillas) de VHD
#     PTE - Añadir la version de OS de la plantilla como parámetro hasta que la deteccion funcione
#     PTE - Intento usando Get-WindowsEdition -path X:\ -Verbose, pero la deteccion del OS Version. No la consigo como una variable.

# Cuando se instenta instalar una version que no coincide obtendremos este evento:
# WARNING: Add-WindowsPackage failed. Error code = 0x800f081e

# !!! Comentar la linea que se desee usar !!!
#############################################
# Quitar el comentario para las version 2012/2012R2 o 2008R2/W7 segun convenga.
$integrationServicesCabPath="C:\Windows\vmguest\support\amd64\Windows6.x-HyperVIntegrationServices-x64.cab"
#$integrationServicesCabPath="C:\Windows\vmguest\support\amd64\Windows6.2-HyperVIntegrationServices-x64.cab"

$VMs = Get-VM | ? {$_.State -eq "off"} | %{$_.Name}

foreach ($vm in $vms) 
    {
    # Expected data like: $virtualHardDiskToUpdate="D:\client_professional_en-us_vl.vhd"
    $virtualHardDiskToUpdate = Get-VMHardDiskDrive -VMName $vm -ControllerType IDE -ControllerLocation 0 -ControllerNumber 0 | %{$_.Path}
    
    #Mount the VHD
    $diskNo=(Mount-VHD -Path $virtualHardDiskToUpdate –Passthru).DiskNumber

    #Get the driver letter associated with the mounted VHD
    $driveLetter=(Get-Disk $diskNo | Get-Partition).DriveLetter

    #Install the patch
    if ($driveLetter.Length -eq "1") 
        {[string]$drive = $driveLetter[0]+":\"
          Write-host " Adding CAB to the offline image for VM: $vm" -ForegroundColor Yellow
          Add-WindowsPackage -PackagePath $integrationServicesCabPath -Path $drive}

    else
        {[string]$drive = $driveLetter[1]+":\"
          Write-host " Adding CAB to the offline image for VM: $vm" -ForegroundColor Yellow
          Add-WindowsPackage -PackagePath $integrationServicesCabPath -Path $drive}
        

    Write-Host " The VM $vm has been updated using this VHD $virtualHardDiskToUpdate"
    write-host ""

    #Dismount the VHD
    Dismount-VHD -Path $virtualHardDiskToUpdate
    }

