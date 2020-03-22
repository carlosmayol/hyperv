Set-StrictMode -Version Latest
$files = Get-ChildItem F:\VMsHyperV\VMs -Recurse | %{$_.VersionInfo.FileName}
foreach ($vm in $files) {
$a = compare-vm  -register -Path "$vm"
$a.Incompatibilities[0].Source | Connect-VMNetworkAdapter -SwitchName Private
Import-VM -CompatibilityReport $a 
}