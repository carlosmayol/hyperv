#Hyper-V Nested VM 
#https://github.com/Microsoft/Virtualization-Documentation/blob/live/hyperv-tools/Nested/Enable-NestedVm.ps1

Get-VM LAB3_SHVMs1 | set-VMProcessor -ExposeVirtualizationExtensions $true
Get-VMNetworkAdapter -VMName LAB3_SHVMs1 | Set-VMNetworkAdapter -MacAddressSpoofing On
Get-VM LAB3_SHVMs1 | Set-VMMemory -DynamicMemoryEnabled $false -StartupBytes 8GB

# Enable SecureBoot & Enable TPM - Use GUI or:
#Creating HGS Guardian
New-HgsGuardian -Name 'UntrustedGuardian' -GenerateCertificates

#Checking with guardian
get-hgsguardian

#assigning variable $owner to guardian
$owner = get-hgsguardian 'UntrustedGuardian'

#Generating key protector for TPM to enable it.
$kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
 
#Setting key protector for TPM to enable it.
Set-VMKeyProtector -VMName 'LAB3_SHVMs1' -KeyProtector $kp.RawData

#Enabling virtual TPM on VMName 
Enable-VMTPM -VMNAME 'LAB3_SHVMs1'
