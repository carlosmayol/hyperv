#Expand-SharedVHDX

<#
.SYNOPSIS
    Expands a VHDX shared by a VM-level cluster
.DESCRIPTION
    This script gathers data from your VM cluster and host cluster, evaluates whether there is enough space on the host disk (CSV) to proceed, then prompts for confirmation to proceed.
.PARAMETER VMClusterName
    Name of the cluster running on the VMs.
.PARAMETER VMHostClusterName
    Name of the VM host cluster (Hyper-v)
.PARAMETER ClusteredVolumeLetter
    Volume letter of the shared VHDX on the VM cluster
.PARAMETER NewSizeInGB

.PARAMETER SkipHostDiskSpaceCheck
    Does not evaluate free space on the CSV before expanding
.INPUTS
    None

.OUTPUTS
 
.NOTES

#>


param(
    [parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Name of the cluster created on the VMs sharing the VHDX")]
    [string]
    [alias("FileClusterName")]
    $VMClusterName,

    [parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Name of the cluster hosting the clustered VMs")]
    [string]
    $VMHostClustername,

    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $ClusteredVolumeLetter,

    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [int]
    $NewSizeInGB,

    [parameter(Mandatory=$false)]
    [boolean]
    $SkipHostDiskSpaceCheck = $false
)

Begin {
write-host "Gather data start time: $(Get-Date -DisplayHint DateTime)" -ForegroundColor Green

function Get-DiskScsiLun {
    #SOURCE: http://rvdnieuwendijk.com/2012/05/29/powershell-function-to-get-disk-scsi-lun-number/
     [CmdletBinding()]
      param([Parameter(Mandatory = $false,
                       Position = 0)]
            [alias("Disk")]
            [string] $DeviceID = '*',
            [Parameter(Mandatory = $false,
                       Position = 1,
                       ValueFromPipeline=$true,
                       ValueFromPipelineByPropertyName=$true)]
            [alias("CN")]
            [String[]] $ComputerName = $env:COMPUTERNAME,
            [Parameter(Mandatory=$false,
                       Position = 2)]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
      )
   
      process {
        if ($ComputerName)
        {
          # Loop through all computers in the parameter list
          foreach ($Computer in $ComputerName) {
          try {
            if ($Computer -eq "$($env:COMPUTERNAME)" -or $Computer -eq "." -or $Computer -eq "localhost")
            {
              # Define the Get-WmiObject parameter set for the local computer
              $Parameters = @{
                Impersonation = 3
                ErrorAction = 'Stop'
              }
            }
            else
            {
              # Define the Get-WmiObject parameter set for remote computers
              $Parameters = @{
                ComputerName = $Computer
                Credential = $Credential
                ErrorAction = 'Stop'
              }
            }
           
            # Test if the computer can be connected
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)     
            {         
              # Get the  WMI objects
              $Win32_LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk @Parameters |
                Where-Object {$_.DeviceID -like $DeviceID}
              $Win32_LogicalDiskToPartition = Get-WmiObject -Class Win32_LogicalDiskToPartition @Parameters 
              $Win32_DiskDriveToDiskPartition = Get-WmiObject -Class Win32_DiskDriveToDiskPartition @Parameters 
              $Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive @Parameters 
   
              # Search the SCSI Lun Unit for the disk
              $Win32_LogicalDisk |
                ForEach-Object {
                  if ($_)
                  {
                    $LogicalDisk = $_
                    $LogicalDiskToPartition = $Win32_LogicalDiskToPartition |
                      Where-Object {$_.Dependent -eq $LogicalDisk.Path}
                    if ($LogicalDiskToPartition)
                    {
                      $DiskDriveToDiskPartition = $Win32_DiskDriveToDiskPartition |
                        Where-Object {$_.Dependent -eq $LogicalDiskToPartition.Antecedent}
                      if ($DiskDriveToDiskPartition)
                      {
                        $DiskDrive = $Win32_DiskDrive |
                          Where-Object {$_.__Path -eq $DiskDriveToDiskPartition.Antecedent}
                        if ($DiskDrive)
                        {
                          # Return the results
                          New-Object -TypeName PSObject -Property @{
                            Computer = $Computer
                            DeviceID = $LogicalDisk.DeviceID
                            SCSIBus = $DiskDrive.SCSIBus
                            SCSIPort = $DiskDrive.SCSIPort
                            SCSITargetId = $DiskDrive.SCSITargetId
                            SCSILogicalUnit = $DiskDrive.SCSILogicalUnit
                          }
                        }
                      }
                    }
                  }
                }
              }
              else
              {
                Write-Warning "Unable to connect to computer $Computer."
              }
            }
            catch {
              Write-Warning "Unable to get disk information for computer $Computer.`n$($_.Exception.Message)"
            }
          }
        }
      }
    }

function Expand-Volume {
    [CmdletBinding(DefaultParametersetName="VolumeLetter")]

    param(
        [parameter(Mandatory=$true,ParameterSetName="VolumeLetter")]
        #[ValidateLength(1)]
        [char]
        $DriveLetter,
    
        [parameter(Mandatory=$true,ParameterSetName="VolumeObject",ValueFromPipeline=$true)]
        #system.object]
        $VolumeObject,

        [parameter(Mandatory=$true,ParameterSetName="VolumeObject",ValueFromPipeline=$true)]
        [parameter(Mandatory=$true,ParameterSetName="VolumeLetter")]
        [string]
        $ComputerName    
        )
        
        Switch ($PSCmdlet.ParameterSetName)
        {
            "VolumeLetter" {$volume = $DriveLetter}
            "VolumeObject" {$volume = $VolumeObject}
            }    

        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            $ParamSetName = $Args[0]
            $Volume = $Args[1]

            Function Parse-DiskpartVolList {
                $Pattern = [regex]"(?msx)^\s\sVolume\s(?<VolNumber>\d+)\s{4,5}(?<VolLetter>[\w\s])\s\s\s(?<VolLabel>[\w\s-_]{11})\s"
                $diskpartVols = ('list vol' | diskpart)

                $patternMatches = @()
                $volObjects = @()
                $patternMatches = $diskpartVols | select-string -pattern $Pattern -AllMatches 
                ForEach ($patternMatch in $patternMatches) {
                    $volObjects += New-Object psobject -Property @{
                        'volNumber'=$patternMatch.matches.groups[1].Value;
                        'VolLetter'=$patternMatch.matches.groups[2].Value;
                        'volLabel'=$patternMatch.matches.groups[3].Value}
                    }

                $volObjects
            }

            Update-HostStorageCache
            try {
                Switch ($ParamSetName)
                    {
                        "VolumeLetter" {
                            Write-Verbose "`tVolume original size: $((get-volume $volume).Size)"
                            $DiskpartVols = Parse-DiskpartVolList
                            $MatchVols = $DiskpartVols.Where( {$_.volLetter -eq $Volume} )
                            If (-not $MatchVols) {
                                Write-Warning "No matching volume with letter '$Volume' was found in DiskPart output. Attempting PowerShell expansion"
                                $UsePowershellMethod = $true
                            }
                            ElseIf ($MatchVols.count -gt 1) {
                                Write-Warning "More than one volume matched volume letter '$Volume'--someone screwed up the regular expression"
                                $UsePowershellMethod = $true
                            }
                            Else {
                                "Select Volume $($MatchVols.volNumber)","Extend" | DiskPart
                                $UsePowershellMethod = $false
                            }

                            If ($UsePowershellMethod -eq $true) {
                                write-host "`tGetting volume max size..."
                                $maxSize = (Get-PartitionSupportedSize -DriveLetter $Volume).SizeMax
                                write-host "`tResizing partition..." 
                                Resize-Partition -DriveLetter $Volume -Size $maxSize
                                write-host ("`tNew size:" + "{0:N1}" -f ((get-volume -path $Volume.path).Size/1GB) + "GB")
                                }
                            Write-Verbose "`tVolume new size: $((get-volume $volume).Size)"
                            }
                        "VolumeObject" {
                            $volume = $VolumeObject
                            Write-Verbose "`tVolume original size: $($volume.size)"
                            $DiskpartVols = Parse-DiskpartVolList
                            $MatchVols = $DiskpartVols.Where( {($_.volLetter -eq $Volume.DriveLetter) -or ($_.volLabel -eq $Volume.FileSystemLabel.Substring(0,11)) } )
                            If (-not $MatchVols) {
                                Write-Warning "No matching volume with letter '$Volume' was found in DiskPart output. Attempting PowerShell expansion"
                                $UsePowershellMethod = $true
                            }
                            ElseIf ($MatchVols.count -gt 1) {
                                Write-Warning "More than one volume matched volume letter '$Volume'--someone screwed up the regular expression"
                                $UsePowershellMethod = $true
                            }
                            Else {
                                "Select Volume $($MatchVols.volNumber)","Extend" | DiskPart
                                $UsePowershellMethod = $false
                            }
                            
                            If ($UsePowershellMethod -eq $true) {
                                write-host "`tGetting partition to resize..." -ForegroundColor Green    
                                $partition  = ($volume | Get-Partition)
                                write-host ("`tOriginal size: " + ($originalSize = "{0:N1}" -f  (($partition).size/1gb)) + "GB") -ForegroundColor Green
                                write-host "`tQuerying partition for maximum new size (may take a minute)..." -ForegroundColor Green
                                $maxSize = ($partition | Get-PartitionSupportedSize).SizeMax
                                write-host ("`tResizing partition to " + ("{0:N1}" -f ($maxSize/1GB)) + "GB ...") -ForegroundColor Green
                                $partition | Resize-Partition -Size $maxSize
                                write-host ("`tNew size:" + "{0:N1}" -f ((get-volume -path $Volume.path).Size/1GB) + "GB")
                                }
                            Write-Verbose "`tVolume new size: $(($volume | get-volume).Size)"
                            
                            }
                    }
                 }
            catch
                {
                    Write-Error "Failed to resize partition. Ensure that storage server has fully allocated new space and letter is correct (try get-volume)." 
                    $_
                }
            } -ArgumentList $PSCmdlet.ParameterSetName,$Volume
}

function GetVolumeOnVMs {
    param (
        [parameter(Mandatory=$true)]
        [string]
        $ClusteredVolumeLetter,

        [parameter(Mandatory=$true)]
        [string[]]
        $VMNames
    )

    $VMVolume = @()
    ForEach ($VMName in $VMNames) {
        $VMVolumeReturn = Invoke-Command -ComputerName $VMName -ArgumentList $ClusteredVolumeLetter -ScriptBlock {
                $VMVolume + @()
                $VMVolume += Get-Volume -FileSystemLabel $args[0] -ErrorAction SilentlyContinue
                $VMVolume += Get-Volume -DriveLetter $args[0] -ErrorAction SilentlyContinue
                If(!([string]::IsNullOrEmpty($VMVolume))){Return $VMVolume}
            }
        $VMVolume += ($VMVolumeReturn | % {$_})
    }

    If ($VMVolume.Count -ne 1) {
        Write-Error "Either none or more than one volume was returned from the clustered VMs--identifier `'$ClusteredVolumeLetter`' may be ambiguous or the cluster resource may already be offline."
        Break}    

    If ($VMVolume.DriveLetter -notmatch "[A-Z]") {
        Write-Error "At this time, the volume on the VMs must be assigned a drive letter"
        Break
    }

    Return $VMVolume
    }
}

Process {
$VerbosePreference = "Continue" #Enable default verbose output
Write-Verbose "Gathering data for resize operation:"

# 1. Get VMs and VM Cluster groups
    
    Write-Verbose "`t1. a) Getting cluster node names for `'$VMClusterName`'"
    Try {Get-Cluster -Name $VMClusterName | Out-Null} 
    Catch {Write-Error "VMClusterName `'$VMClusterName`' could not be found. Exiting..."; break}
    $VMNames = (Get-ClusterNode -Cluster $VMClusterName |%{$_.Name})

    Write-Verbose "`t1. b) Getting cluster group names for VM cluster node member in VM host cluster"
    Try {Get-Cluster -Name $VMHostClustername | Out-Null} 
    Catch {Write-Error "VMHostClusterName `'$VMHostClustername`' could not be found. Exiting..."; break}
    $VMClusterGroups = Get-ClusterGroup -Cluster $VMHostClustername -Name $VMNames

    If ($VMNames.count -ne $VMClusterGroups.count) {
        Write-Error "Not all VMs in the specified VM cluster were found on the host cluster, script cannot proceed. VMs sharing a VHDX will be in the same host cluster."
        Break
    }

    $VMPSSessions = @()
    For ($i=1 ; $i -le $VMNames.Count; $i++) {
        Remove-Variable -Name "VMSession$($i - 1)" -ErrorAction SilentlyContinue
        (New-Variable -name "VMSession$($i - 1)" -Value (New-PSSession -ComputerName $VMNames[$i - 1] -Name "VMSession_$($VMNames[$i - 1])" -Verbose))
        $VMPSSessions += Get-Variable -Name "VMSession$($i - 1)" -ValueOnly
    }

# 2. Get volumes on VMs

    Write-Verbose "`t2. Getting specified volume (`'$ClusteredVolumeLetter`:\`') on VMs"
    $VMVolume = GetVolumeOnVMs -ClusteredVolumeLetter $ClusteredVolumeLetter -VMNames $VMNames

  #2a Set Target VM
  $VMVolOwnerSession = $VMPSSessions | Where-Object {$_.Name -like "VMSession_$($VMVolume.PSComputerName)"}

# 3. Get VM cluster volume cluster resource

    Write-Verbose "`t3. Getting cluster disk resource for volume on VM cluster"
    $VMVolumeClusterResource = Invoke-Command -Session $VMVolOwnerSession -ScriptBlock {Return ($args[0] | Get-Partition | Get-Disk | Get-ClusterResource)} -ArgumentList $VMVolume

    If ($VMVolumeClusterResource -eq $null) {
        Write-Error "Could not find associated cluster resource for VM volume"
        Break
    }

# 4. Get VHDX File
    Write-Verbose "`t4. Getting VHDX file info on the VM cluster host"
    $VMVolumeSCSIInfo = Get-DiskScsiLun -DeviceID "$($VMVolume.DriveLetter)`:" -ComputerName $VMVolOwnerSession.ComputerName
    Write-Verbose "`t`t`tVM Volume SCSI Info: `n            $($VMVolumeSCSIInfo)"
    $VMHostVHDXPath = (($VMClusterGroups | Where-Object {$_.Name -like "*$($VMVolOwnerSession.ComputerName)*"}) | `
        get-VM | Get-VMHardDiskDrive -ControllerNumber $VMVolumeSCSIInfo.SCSIPort -ControllerLocation $VMVolumeSCSIInfo.SCSILogicalUnit).Path
    Write-Verbose "`t`t`tVHDX Path: $VMHostVHDXPath"
    $VMHostVHDXType = Invoke-Command -ComputerName $VMClusterGroups[0].OwnerNode -ScriptBlock {(Get-VHD -Path $args[0]).VhdType} -ArgumentList $VMHostVHDXPath
    Switch ($VMHostVHDXType) {
        "2" {$VMHostVHDXType = "Fixed"}
        "3" {$VMHostVHDXType = "Dynamic"}
    }
    Write-Verbose "`t`t`tVHDX Type: $VMHostVHDXType"
    $VHDXFileSize = Invoke-Command -ComputerName $VMClusterGroups[0].OwnerNode -ScriptBlock {(Get-Item -Path $args[0]).Length} -ArgumentList $VMHostVHDXPath
    Write-Verbose "`t`t`tVHDX Size: $($VHDXFileSize / 1GB)GB"

    If ($VMHostVHDXPath -eq $null) {
        Write-Error "Unable to find a VMHardDiskDrive for the specified VM volume"
    }

# 5. Get VM host volume
    Write-Verbose "`t5. Getting VHDX host volume on VM host cluster"
    $VMHostCSVMountPoint = ($VMHostVHDXPath.Split("\") | select -Index 0,1,2) -join "\"
    $VMHostVolume = Invoke-Command -ComputerName $VMClusterGroups[0].OwnerNode -ScriptBlock {Return (Get-Volume -FilePath $args[0])} -ArgumentList $VMHostCSVMountPoint

# 6. Verify Resize Request
    Write-Verbose "`t6. Checking that request does not exceed capacity + reserve on VM host cluster disk"
    $VHDXGrowthGB = $NewSizeInGB - ($VHDXFileSize/1GB)
    $CSVFreeGB = $VMHostVolume.SizeRemaining/1GB

    Write-Verbose "`t`tNew size requested minus current size (growth potential): $("{0:N2}" -f $VHDXGrowthGB)`GB"
    Write-Verbose "`t`tCurrent free space on CSV: $("{0:N2}" -f $CSVFreeGB)GB"
    Write-Verbose "`t`tSpace available if VHDX fully expands $("{0:N2}" -f ($CSVFreeGB - $VHDXGrowthGB))GB"
    Write-Verbose "`t`tHost volume 5% buffer: $("{0:N2}" -f (($VMHostVolume.Size * .05) /1GB))GB"
    If (!($SkipHostDiskSpaceCheck) -and (($CSVFreeGB - $VHDXGrowthGB) * 1GB) -lt ($VMHostVolume.Size * .05)) {
        Write-Verbose "`t`tHost volume will have $("{0:N2}" -f ((($CSVFreeGB - $VHDXGrowthGB) / ($VMHostVolume.Size/1GB)) * 100))% free after assuming full VHDX expansion"  
        Write-Error "Requested size will leave the parent disk with less than 5% free if occupied. Please expand the CSV"
        break
    }
    ElseIf (($SkipHostDiskSpaceCheck) -and ($VMHostVHDXType -eq "Fixed")) {
        Write-Warning "Overriding skipping host disk space validation because VHDX type is 'FIXED'!"
        Write-Verbose "`t`tHost volume will have $("{0:N2}" -f ((($CSVFreeGB - $VHDXGrowthGB) / ($VMHostVolume.Size/1GB)) * 100))% free after assuming full VHDX expansion"  
        If ((($CSVFreeGB - $VHDXGrowthGB) * 1GB) -lt ($VMHostVolume.Size * .01)) {
            Write-Error "Requested size will leave the parent disk with less than 1% free if occupied. Please expand the CSV"
            break
        }
    }
    ElseIf ($SkipHostDiskSpaceCheck) {
        Write-Warning "Skipping parent disk size check"
    }
    Else {
        Write-Verbose "`t`tHost volume will have $("{0:N2}" -f ((($CSVFreeGB - $VHDXGrowthGB) / ($VMHostVolume.Size/1GB)) * 100))% free after assuming full VHDX expansion"  
    }

<# 7. Proceed with Resize
        a. Offline VM cluster volume resource
        b. Remove the VM cluster volume VHDX from all VM cluster nodes
        c. Resize the VHDX
        d. Reattach the VHDX to all hosts
        e. Online the VM cluster disk resource, suspend to allow volume expand
        f. Expand the VM cluster volume 
        g. Resume the vm cluster disk resource and group  
#>

write-host "Gather data end time: $(Get-Date -DisplayHint DateTime)" -ForegroundColor Red
write-host "Gathering info complete, press ENTER to proceed!" -ForegroundColor Cyan
Read-Host 

Try {
write-host "Expand operation start time: $(Get-Date -DisplayHint DateTime)" -ForegroundColor Green
#a.
        Try {
            Write-Verbose "Stopping VM volume disk cluster resource"
            Stop-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName | Out-Null
        }
        Catch {
            Write-Error "Unable to offline the VM cluster resource. Aborting... `n $_"
            Break 
        }
#b.
        Try {
            Write-Verbose "Removing VHDX from each VM cluster node"
            ForEach ($VMClusterGroup in $VMClusterGroups) {
                $VMVHDX = Get-ClusterGroup -Name $VMClusterGroup.Name -Cluster $VMHostClustername | `
                    Get-VM | `
                    Get-VMHardDiskDrive | `
                    Where-Object {$_.Path -like $VMHostVHDXPath}
                Remove-VMHardDiskDrive -ComputerName $VMClusterGroup.OwnerNode -VMName $VMVHDX.VMName -ControllerType SCSI -ControllerNumber $VMVHDX.ControllerNumber -ControllerLocation $VMVHDX.ControllerLocation -Verbose
                }
            }
        Catch {
            Write-Error "Failed to remove VHDX from one of the VM cluster nodes. Attempting rollback. `n $_"
                ForEach ($VMClusterGroup in $VMClusterGroups) {
                    Write-Host "Reattaching VHDX to $($VMClusterGroup.Name)..." -ForegroundColor DarkMagenta
                    Add-VMHardDiskDrive -ComputerName $VMClusterGroup.OwnerNode -VMName $VMClusterGroup.Name -ControllerType SCSI -Path $VMHostVHDXPath -SupportPersistentReservations:$true
                    }
                    Write-Host "Starting volume cluster resouce" -ForegroundColor DarkMagenta
                    Start-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName
                    break
                }
#c.
        Try {
            Write-Verbose "Resizing VHD to requested size of $NewSizeInGB`GB"
            Resize-VHD -ComputerName $VMClusterGroups[0].OwnerNode -Path $VMHostVHDXPath -SizeBytes ($NewSizeInGB * 1GB) -Verbose
            }
        Catch {
            Write-Error "Failed to resize VHDX $($VMHostVHDX.Path) on $($VMClusterGroups[0].OwnerNode). Attemping rollback. `n $_"
                ForEach ($VMClusterGroup in $VMClusterGroups) {
                    Write-Host "Reattaching VHDX to $($VMClusterGroup.Name)..." -ForegroundColor DarkMagenta
                    Add-VMHardDiskDrive -ComputerName $VMClusterGroup.OwnerNode -VMName $VMClusterGroup.Name -ControllerType SCSI -Path $VMHostVHDXPath -SupportPersistentReservations:$true
                    }
                    Write-Host "Starting volume cluster resouce" -ForegroundColor DarkMagenta
                    Start-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName
                    Break
        }
#d.
        Try {
            ForEach ($VMClusterGroup in $VMClusterGroups) {
                Write-Verbose "Reattaching VHDX to $($VMClusterGroup.Name)..."
                
                $RetryAttachCount = 0
                Do {
                    $RetryAttachCount ++
                    Write-Verbose "`tAttempting to reattach VHDX to VM $($VMClusterGroup.Name). Attempt ($RetryAttachCount of 3)"
                    Add-VMHardDiskDrive -ComputerName $VMClusterGroup.OwnerNode -VMName $VMClusterGroup.Name -ControllerType SCSI -Path $VMHostVHDXPath -SupportPersistentReservations:$true
                    }
                Until ($? -or $RetryAttachCount -eq 3)
                If ($RetryAttachCount -gt 2){
                    Throw "Failed to attach VHDX to $($VMClusterGroup.Name) after 3 attempts."
                   }
                }
        }
        Catch {
            Write-Error "Failed to reattach VHDXs back to all guests. MANUAL ACTION REQURED: Attach VHDXs, start cluster resource, expand volume. `n $_"
            Break
        }
#e.
        Try {
            Write-Verbose "Starting volume cluster resouce, then putting it in maintenance mode" 
            Start-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName | Out-Null
            Suspend-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName | Out-Null
        }
        Catch {
            Write-Error "Failed to online or suspend the cluster resource. MANUAL ACTION REQUIRED: Start cluster resource, Expand volume. `n $_"
            break
        }
#f
        Try {
            Write-Verbose "Expanding volume on VM node, then stopping maintenance mode"
            $VMVolume = GetVolumeOnVMs -ClusteredVolumeLetter $ClusteredVolumeLetter -VMNames $VMNames
            Expand-Volume -DriveLetter $ClusteredVolumeLetter -ComputerName $VMVolume.PSComputerName            
        }
        Catch {
            Write-Error "Failed to expand volume `'$ClusteredVolumeLetter`' on VM $($VMVolume.PSComputerName). MANUAL ACTION REQUIRED: Expand volume, Resume Cluster Resource and/or Group `n $_"

            Break
        }
#g.
        Try {        
            Write-Verbose "Resuming cluster resource"
            Resume-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName | Out-Null
            Write-Verbose "Checking that cluster resource owning group is also resumed; if not, resuming."
            $VMVolumeClusterResourceOwnerGroup = Get-ClusterGroup $VMVolumeClusterResource.OwnerGroup -Cluster $VMClusterName
            If ($VMVolumeClusterResourceOwnerGroup.State -ne "Online") {
                $VMVolumeClusterResourceOwnerGroup | Start-ClusterGroup -Cluster $VMClusterName | Out-Null
                }
        }
        Catch {
            Write-Error "Failed to resume cluster resource and/or cluster group. MANUAL ACTION REQUIRED:  Resume Cluster Resource and/or Group `n $_"
            Resume-ClusterResource $VMVolumeClusterResource -Cluster $VMClusterName
            $VMVolumeClusterResourceOwnerGroup | Start-ClusterGroup -Cluster $VMClusterName
        }
    }
    Catch {
        Write-Error "Unspecified Error `n $_"
    }
}

End {
    $VMPSSessions | %{ $_ | Remove-PSSession -Confirm:$false}
    Write-Host "Stop time: $(Get-Date -DisplayHint DateTime)" -ForegroundColor Red
}