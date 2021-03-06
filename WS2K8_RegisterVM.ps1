# RegisterVM.ps1  - Registers a Hyper-V’s VM that was not previously exported 
# Usage: ./RegisterVM.ps1 <path to VM's xml file> 
# Example: ./RegisterVM.ps1 "D:\VirtualMachines\test\Virtual Machines\D73AF4BF-3F52-4DE0-85BA-ADB457E31C37.xml"

param([parameter(Mandatory=$TRUE,ValueFromPipeline=$TRUE)] $VMXMLPath)

# Adding MKLINK function as CreateSymbolicLink

$signature = @" 
using System; 
using System.Runtime.InteropServices;

namespace System 
{ 
public class MkLink 
{ 
  [DllImport("kernel32.dll")] 
  public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags); 
} 
} 
"@

Add-Type -TypeDefinition $Signature

# Hard-coded default Virtual Machines and Snapshots paths in Hyper-V Host

$VMsLNKS = "C:\ProgramData\Microsoft\Windows\Hyper-V\Virtual Machines" 
$SnapshotsLNKS = "C:\ProgramData\Microsoft\Windows\Hyper-V\Snapshots"

# Read VM's configuration file

Trap [System.Management.Automation.ErrorRecord] {write-host("File not found, or it is invalid") -Foregroundcolor Yellow; Break} 
[xml]$VMCONFIG = get-content $VMXMLPath -EA Stop

# Get VM's XML file name and Service ID from VM's configuration file name. If you are using a localized version of Windows you must translate this string

$VMFile =  [io.path]::GetFileName($VMXMLPath) 
$VMPath =  [io.path]::GetDirectoryName($VMXMLPath) 
$ServiceID = "NT VIRTUAL MACHINE\"+$VMFile.Replace(".xml", "")


# Get VM's Name. If the attribute does not exist, we assume this is not a VM's XML Configuration file

if ($vmconfig.configuration.properties.name -eq "properties"){ 
    write-host("The file does not look like a VM's XML file") -Foregroundcolor Yellow 
    Throw ("Now exiting") 
    }

$VMname = $vmconfig.Configuration.properties.name.Get_InnerText()

# Read available VM's storage

$Disks = $vmconfig.configuration.GetElementsByTagName("pathname")

# Create VM's Hard Link and set ACLs

write-host ("Rebuilding Hardlink") -Foregroundcolor Yellow

$hardlink=[system.MkLink]::CreateSymbolicLink($VMsLNKS+"\"+$VMFile,$VMXMLPath,0) 
IF (!$hardlink){ 
    write-host("Failed to create the hard link") -Foregroundcolor Yellow 
    }

# Wait 10 seconds until VMMS Service creates de NT VIRTUALMACHINE\VM ID user. 


write-host ("Waiting for Service ID") -Foregroundcolor Yellow 
Start-Sleep 10

write-host ("Securing Hard Link and VM's State files") -Foregroundcolor Yellow 
    
icacls $VMsLNKS"\"$VMFile /grant $ServiceID":(F)" /L 
icacls $VMPath /grant $ServiceID":(F)" /T

# Check whether Snapshots exists or not, and read them. Create their Hard Links and set ACLs

Trap [System.Management.Automation.RuntimeException] {write-host("Snapshots directory is not set in VM's XML configuration file") -Foregroundcolor Yellow ; Continue} 
If ($vmconfig.configuration.global_settings.snapshots.list.size.Get_InnerText() -ne "0"){ 
    write-host ("Rebuilding Snapshots") -Foregroundcolor Yellow 
    $Snapshotspath = $vmconfig.configuration.global_settings.snapshots.data_root.Get_InnerText() 
    $Snapshots = $vmconfig.configuration.GetElementsByTagName("guid") 
    foreach ($_ in $snapshots) { 
        if ($_.Get_InnerText()){ 
            $snap = $_.Get_InnerText()+".xml" 
            [system.MkLink]::CreateSymbolicLink($SnapshotsLNKS+"\"+$snap,$Snapshotspath+"\Snapshots\"+$_.Get_InnerText()+".xml",0) 
            icacls $SnapshotsLNKS"\"$snap /grant $ServiceID":(F)" /L 
            icalcs $Snapshotspath /grant $ServiceID":(F)" /T 
            } 
        } 
    }

# Set ACLs for every VHD (not pass-through Disks)

write-host ("Rebuilding VHD Permissions") -Foregroundcolor Yellow

foreach ($_ in $Disks) { 
    if ($_.Get_InnerText().ToLower().Contains("vhd")){ 
    $Disk = $_.Get_InnerText() 
    icacls $disk /grant $ServiceID":(F)" 
    } 
}

write-host ("Done: Check Hyper-V Manager for the virtual machine") -Foregroundcolor Yellow 