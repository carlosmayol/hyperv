# Este script solo funciciona con VMs 2008/Vista o superior. Valido solo para VMs Generation 1
# Este script debe ejecutarse en el HOST de Hyper-V de forma local.
#      La version Windows6.x-HyperVIntegrationServices-x64.cab es compatible con Win2008/vista/2008R2/W7
#      La version Windows6.2-HyperVIntegrationServices-x64.cab es compatible con Win2012 y superior

# v2, Usando KVP info en la VM, previo a parar la VM, por lo que la VM debe estar running. 
#     Opción para las VMs que estan en produccion & "running".
#     PTE - Generar una version que se pueda lanzar en remoto sobre un cluster
#     PTE - Añadir soporte para Gen2, detectar version de HOST y de VM.

# Cuando se instenta instalar una version que no coincide con el OSVersion obtendremos este evento:
# WARNING: Add-WindowsPackage failed. Error code = 0x800f081e

Set-StrictMode -Version Latest

# Filter for parsing XML data from KVP
filter Import-CimXml 
{ 
   # Create new XML object from input
   $CimXml = [Xml]$_ 
   $CimObj = New-Object -TypeName System.Object 
 
   # Iterate over the data and pull out just the value name and data for each entry
   foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='Name']")) 
      { 
         $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE 
      } 
 
   foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY[@NAME='Data']")) 
      { 
         $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE 
      } 
 
   # Display output
   $CimObj 
} 


# CAB Path definition
$IC6X="C:\Windows\vmguest\support\amd64\Windows6.x-HyperVIntegrationServices-x64.cab"
$IC62="C:\Windows\vmguest\support\amd64\Windows6.2-HyperVIntegrationServices-x64.cab"

Clear-Host

# Prompt for the virtual machine to use
write-host "" 
write-host "##############################################################" -ForegroundColor white
$VMName = Read-Host "Specify the name or string to match virtual machine/s"
write-host "##############################################################" -ForegroundColor white
write-host ""


$VMs = Get-VM | ? {($_.Name -match "$vmname") -and ($_.State -eq "Running")} | %{$_.Name}

write-host "" 
write-host "##################################################" -ForegroundColor White
write-host "   Caution: These VMs will be shutdown : " -ForegroundColor red
write-host "##################################################" -ForegroundColor White
write-host ""

$VMs | ft Name, State
write-host ""
Pause
write-host ""


foreach ($vm in $vms) 
    {

    # Get the virtual machine object
    $query = "Select * From Msvm_ComputerSystem Where ElementName='" + $vm + "'"
    $Vm2 = gwmi -namespace root\virtualization\v2 -query $query 
 
    # Get the KVP Object
    $query = "Associators of {$Vm2} Where AssocClass=Msvm_SystemDevice ResultClass=Msvm_KvpExchangeComponent"
    $Kvp = gwmi -namespace root\virtualization\v2 -query $query
 
    # Write-Host
    # Write-Host "Guest KVP information for" $vm2
 
    # Filter the results
    # $Kvp.GuestIntrinsicExchangeItems | Import-CimXml 
    
    $vmos= $Kvp.GuestIntrinsicExchangeItems | Select-String Osversion | Import-CimXml | %{$_.Data}

    $integrationServicesCabPath = $null

    if ($vmos -match "6.0")
        {
        #OS is Windows 2008R2
        $integrationServicesCabPath = $IC6X
        }
    
    if ($vmos -match "6.1")
        {
        #OS is Windows 2008R2
        $integrationServicesCabPath = $IC6X
        }
        
     if ($vmos -match "6.2")
        {
        #OS is Windows 2012
        $integrationServicesCabPath = $IC62
        }

    If ($vmos -ne $null)
        
        { 

            #Stopping the VM
            write-host "`t` Stopping the VM: $vm, please wait the OS to respond the gracefully shutdown request...." -ForegroundColor White
            stop-vm -Name $vm

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
                  Write-host "`t` Adding CAB to the offline image for VM: $vm" -ForegroundColor Yellow
                  Add-WindowsPackage -PackagePath $integrationServicesCabPath -Path $drive}
        

            Write-Host "`t` The VM $vm has been updated using this VHD $virtualHardDiskToUpdate" -ForegroundColor Yellow
            write-host ""

            #Dismount the VHD
            Dismount-VHD -Path $virtualHardDiskToUpdate

            #Starting the VM
            write-host "`t` Starting the VM: $vm ...." -ForegroundColor White
            start-vm -Name $vm
          } 
    }

 






