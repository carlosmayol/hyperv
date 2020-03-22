#Hyper-V Blitz 
#Version 1.0

# v1.1 CarlosM

foreach ($ComputerName in $args)
    {

    Write-Host " "
    Write-Host "***************************"
    Write-Host "Hyper-V Host Configurations"
    Write-Host "***************************"
    Write-Host
        
    $Hosts = Get-VMHost -ComputerName $ComputerName
    $Hosts | ft Name, LogicalProcessorCount, MemoryCapacity, ExternalNetworkAdapters -Auto

    Get-VMHost -ComputerName $ComputerName | Export-CSV -append -Path Hosts.csv
    
    
    Write-Host "Hyper-V Virtual Machines"

    $VMs = Get-VM -ComputerName $ComputerName
    $VMs | ft -Auto

    Get-VM -ComputerName $ComputerName | Export-CSV -append VMs.csv
    

    Write-Host "************"
    Write-Host "Hyper-V VHDs"
    Write-Host "************"
    Write-Host " "

    
    
    foreach($VM in $VMs)
    { 

      $VHDs = Get-VHD -VMId $VM.VMiD -ComputerName $ComputerName 
      $VHDsGB = [math]::truncate($VHDs.FileSize / 1MB)
      Write-Host $VM.Name, $VHDs.Path, $VHDsGB "(MB)" | ft -Auto
      Write-Host " "
      
      # Added an Append switch ya que si no, solo exporta el ultimo valor del VHD, ello implica que este fichero no es recreado cada vez y es conveniente borrarlo.
      $VHDs | Export-CSV -append VHDs.csv

    }


    Write-Host " "
    Write-Host "************"
    Write-Host "Hyper-V Snapshots"
    Write-Host "************"
    Write-Host " "

    $Snapshots = Get-VM -ComputerName $ComputerName | Get-VMSnapshot
    $Snapshots | ft -Auto

    Get-VM -ComputerName $ComputerName | Get-VMSnapshot | Export-CSV -append Snapshots.csv

        
    Write-Host "****************"
    Write-Host "Hyper-V Switches"
    Write-Host "****************"
    Write-Host " "

    $Switches = Get-VMSwitch -ComputerName $ComputerName
    $Switches | ft -Auto

    Get-VMSwitch -ComputerName $ComputerName | Export-CSV -append .\Switches.csv


    Write-Host "****************"
    Write-Host "Hyper-V Replication Settings"
    Write-Host "****************"
    Write-Host " "
    
    Get-VM -ComputerName $ComputerName | ft Name, ReplicationState
    Get-VM -ComputerName $ComputerName | Export-CSV -append .\Replica.csv
    

    }