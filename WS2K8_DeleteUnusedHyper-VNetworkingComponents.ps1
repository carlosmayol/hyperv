#################################################################################
# Copyright © Microsoft Corporation.  All Rights Reserved.                      #
#################################################################################
# Microsoft Corporation (or based on where you live,                            #
# one of its affiliates) licenses this sample scripts for                       #
# your internal testing purposes only. Microsoft provides                       #
# the following sample scripts AS IS without warranty of any kind.              #
# The sample scripts are not supported under any Microsoft standard             #
# support program or services. Microsoft further disclaims all                  #
# implied warranties including, without limitation, any implied                 #
# warranties of merchantability or of fitness for a particular                  #
# purpose. The entire risk arising out of the use or performance                #
# of the sample scripts remains with you. In no event shall Microsoft,          #
# its authors, or anyone else involved in the creation, production,             #
# or delivery of the scripts be liable for any damages whatsoever               #
# (including, without limitation, damages for loss of business profits,         #
# business interruption, loss of business information, or other pecuniary loss) #
# arising out of the use of or inability to use the sample scripts,             #
# even if Microsoft has been advised of the possibility of such damages.        #
#################################################################################


#region common Stuff

function printHelp
{
   Write-Host "Usage: DeleteUnusedHyper-VNetworkingComponents.ps1 <HostName> [yes|no]"
   Write-Host "`t<HostName> is the name of the host to connect"
   Write-Host "`t[yes|no]. Default: No."
   Write-Host "`t`tIf 'yes', it deletes the orphan SwitchPorts."
   Write-Host "`t`tIf 'no', it doe not delete the orphan SwitchPorts, just prints the output."
   
   exitScript
}

function exitScript
{
  Write-Host "Done"
  exit
}

if ($args.Count -lt 1 -or $args.Count -gt 2)
{
   printHelp
}

$delete = $false
Write-Host ""
if ($args.Count -ne 2)
{
   Write-Host "No action specifed. The Port groups will not be deleted" -ForegroundColor Green   
}
else
{
	$temp = $args[1]
	$delete = $temp.ToLower().CompareTo("yes") -eq 0
	if ($delete)
	{
		   Write-Host "The offending objects will be logged and removed" -ForegroundColor Yellow   
	}
	else
	{
		   Write-Host "The network will not be fixed. Only information of offending obejcts is shown" -ForegroundColor Green
	}
}

Write-Host

# initialze variables

$h = $args[0]
$space = "root\virtualization"
$classPort = "Msvm_SwitchPort"
$classNetwork = "Msvm_VirtualSwitch"
$classSyntheticData = "Msvm_SyntheticEthernetPortSettingData"
$classEmulatedData = "Msvm_EmulatedEthernetPortSettingData"
$classSwitchService = "Msvm_VirtualSwitchManagementService"
$classInternalPort = "Msvm_InternalEthernetPort"
$classExternalPort = "Msvm_ExternalEthernetPort"
$classActiveConnection = "Msvm_ActiveConnection"

write-Host "Cleaning Host `"$h`"" -ForegroundColor "Cyan"

$netService = @(get-wmiObject -ComputerName $h -namespace $space -class $classSwitchService)


if ($netService.Count -ne 1)
{
    Write-Host "Unable to retrieve the $classSwitchService instance. Exiting... "
    exitScript
}

$netService = $netService[0]

# get the virtual networks
Write-Host "Enumerating the Virtual Networks... " -NoNewline
$vns = @(get-wmiObject -ComputerName $h -namespace $space -class $classNetwork)
Write-Host "Done. $($vns.Count) Virtual Network`(s`) found" -ForegroundColor "Green"

#if ($vns.Count -eq 0)
#{
#    Write-Host "No Virtual Networks were found so there is no need to clean this host" -ForegroundColor "Cyan"
#    exitScript
#}

Write-Host "Enumerating all the virtual NICs... " -NoNewline
$allnics = @()
$allnics += @(get-wmiObject -ComputerName $h -namespace $space -class $classSyntheticData)
$allnics += @(get-wmiObject -ComputerName $h -namespace $space -class $classEmulatedData)
# remove those nics without a connection
$allnics = @($allnics | where {$_.Connection.Count -eq 1})
Write-Host "Done. $($allnics.Count) Virtual nic`(s`) found" -ForegroundColor "Green"

# Get all active connections for this host
Write-Host "Enumerating the Active Connections... " -NoNewLine
$connections = @(get-wmiObject -ComputerName $h -namespace $space -class $classActiveConnection)    
Write-Host "Done. $($connections.Count) Connection`(s`) found" -ForegroundColor "Green"

# Get all internal NICs
Write-Host "Enumerating the internal NICs... " -NoNewLine
$inics = @(get-wmiObject -ComputerName $h -namespace $space -class $classInternalPort)
Write-Host "Done. $($inics.Count) internal NIC`(s`) found" -ForegroundColor "Green"

# Get all physical NICs
Write-Host "Enumerating the physical NICs... " -NoNewLine
$pnics = @(get-wmiObject -ComputerName $h -namespace $space -class $classExternalPort)
# lets check only enabled and disabled NICs, all others, we don't know what to do with them, they might be in a weird state
$pnics = @($pnics | where {$_.EnabledState -eq 2 -or $_.EnabledState -eq 3})
#we are only interested in the Bound NICs
$pnics = @($pnics | where {$_.IsBound -ieq "True"})
Write-Host "Done. $($pnics.Count) physical NIC`(s`) found" -ForegroundColor "Green"

#endregion

#region unused switchPorts

# for each VN, we have to clean it
foreach ($vn in $vns)
{
    Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
    Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
    Write-Host "Examining VN $($vn.ElementName)" -ForegroundColor "Cyan"
    # Get all the switch ports for this VN
    Write-Host "Enumerating the Switch Ports... " -NoNewLine
    $ports = @(get-wmiObject -ComputerName $h -namespace $space -query "SELECT * FROM $classPort WHERE SystemName='$($vn.Name)'")    
    Write-Host "$($ports.Count) ports found" -ForegroundColor "Green"

    # Get all active connections for this VN and remove them from the list of ports in the VN
    Write-Host "Enumerating the Active Connections... " -NoNewLine
    $vnCon = @()
    $vnCon = @($connections | where {$_.Antecedent -like "*$($vn.Name)*"})
    Write-Host "$($vnCon.Count) connections" -ForegroundColor "Green"
    
    # Now, for each port we look for a Nic connected to the port.
    # If there is no Nic, then we add the port  to the list of ports to remove
    $unusedPorts = @()

    foreach ($port in $ports)
    {
        # check for a connected vNIC
        $nicConnected = @($allnics | where {$_.Connection[0] -like "*$($port.Name)*"})
        # checked for an active connection for this port
        $activeConnection = @($connections | where {$_.Antecedent -like "*$($port.Name)*"})
        
        if ($nicConnected.Count -eq 0 -and $activeConnection.Count -eq 0)
        {
            # The port is not used by a vNIC or an active connection
            $unusedPorts += $port
        }
    }

    if ($($unusedPorts.Count -eq 0))
    {
        Write-Host "No Unused Ports found on virtual Network `"$($vn.ElementName)`"" -ForegroundColor "Green"
    }
    else
    {
        Write-Host "$($unusedPorts.Count) orphan Switch Ports found." -ForegroundColor "Yellow"
		if ($delete)
		{
			Write-Host "Removing Unused ports... "
			foreach ($unusedPort in $unusedPorts)
			{
				$job = $netService.DeleteSwitchPort($unusedPort)
				$result = $job.ReturnValue
				if ($result -ne 0)
				{
					Write-Host "Failed to remove port `"$($port.Name)`". Method call failed with error value $result" -ForegroundColor "Red"
				}
				else
				{
					Write-Host "Port `"$($unusedPort.Name)`" removed successfully" -ForegroundColor "Green"
				}        
			}
		}
    }

    Write-Host "Done Investigating vn `"$($vn.Name)`"" -ForegroundColor "Cyan"
}

Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"

Write-Host "Finished with all Virtual Networks"


#endregion

#region Internal NICs
Write-Host 
Write-Host 
Write-Host 
Write-Host "Fixing internal NICs"

# Check if there is any orphan internal NIC
$unusediNICs = @()
foreach ($inic in $inics)
{
   # get the Active conenction for the internal port. If there's no active connection, then the internal port is orphan
   $internalConnection = @($connections | where {$_.Dependent -like "*$($inic.Name)*"})
   if ($internalConnection.Count -eq 0)
   {
      # the vNIC is orphan. Add it to the list of unused inics
      $unusediNICs += $inic
   }
}

if ($($unusediNICs.Count -eq 0))
{
    Write-Host "No Unused internal NICs found" -ForegroundColor "Green"
}
else
{
    Write-Host "$($unusediNICs.Count) orphan internal NICs found." -ForegroundColor "Yellow"
	if ($delete)
	{
		Write-Host "Removing Unused internal NICs... "
		foreach ($unusediNIC in $unusediNICs)
		{
			$job = $netService.DeleteInternalEthernetPort($unusediNIC)
			$result = $job.ReturnValue
			if ($result -ne 0)
			{
				Write-Host "Failed to remove internal NIC `"$($unusediNIC.ElementName)`". Method call failed with error value $result" -ForegroundColor "Red"
			}
			else
			{
				Write-Host "Internal NIC `"$($unusediNIC.ElementName)`" removed successfully" -ForegroundColor "Green"
			}        
		}
	}
}

Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"

Write-Host "Done Investigating internal NICs" -ForegroundColor "Cyan"

#endregion

#region External NICs

Write-Host 
Write-Host 
Write-Host 
Write-Host "Fixing physical Ethernet Ports"

# Check if there is any orphan internal NIC
$unusedpNICs = @()
foreach ($pnic in $pnics)
{
   # get the Active conenction for the internal port. If there's no active connection, then the internal port is orphan
   if ($externalConnection.Count -eq 0)
   {
      # the vNIC is orphan. Add it to the list of unused inics
      $unusedpNICs += $pnic
   }
}

if ($($unusedpNICs.Count -eq 0))
{
    Write-Host "No Unused physical and Bound physical NICs found" -ForegroundColor "Green"
}
else
{
    Write-Host "$($unusedpNICs.Count) physical NICs not atttached to a Virtual Switch BUT Bound to Hyper-V found." -ForegroundColor "Yellow"
    if ($delete)
	{
		Write-Host "Unbinding bound and unused external NICs... "
		foreach ($unusedpNIC in $unusedpNICs)
		{
			$job = $netService.UnbindExternalEthernetPort($unusedpNIC)
			$result = $job.ReturnValue
			if ($result -ne 0)
			{
				Write-Host "Failed to unbind physical NIC `"$($unusedpNIC.ElementName)`". Method call failed with error value $result" -ForegroundColor "Red"
			}
			else
			{
				Write-Host "physical NIC `"$($unusedpNIC.ElementName)`" unbound successfully" -ForegroundColor "Green"
			}        
		}
	}
}

Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"
Write-Host "+++++++++++++++++++++++++++++++" -ForegroundColor "Blue"

Write-Host "Done Investigating Physical NICs" -ForegroundColor "Cyan"

#endregion


