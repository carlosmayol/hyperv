#.\InjectIP.ps1 -VMName "TestVm1" -NICName "Network Adapter" -IPAddress "10.1.1.12" -Subnet "255.255.255.0" -DefaultGateway "10.1.1.1" -DNSServers "10.1.1.100","10.1.1.101"
#If DefaultGateway is set use -DefaultGateway "" to remove???
param
(
    [parameter(mandatory=$True)]
    $VMName,
    [parameter(mandatory=$True)]
    $NICName,
    [parameter(mandatory=$True)]
    [String[]]$IPAddress,
    #[parameter(mandatory=$True)]
    [String[]]$Subnet,
    #[parameter(mandatory=$True)]
    [String[]]$DefaultGateway,
    #[parameter(mandatory=$True)]
    [String[]]$DNSServers
)

# Get vm object 
$vm = Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_ComputerSystem -Filter "ElementName = '$VMName'" 

# Get active settings 
$vmSettings = $vm.GetRelated('Msvm_VirtualSystemSettingData') | where {$_.VirtualSystemType -eq 'Microsoft:Hyper-V:System:Realized'}

#Get Network Adapters
$netAdapter = $vmSettings.GetRelated('Msvm_SyntheticEthernetPortSettingData') | where {$_.ElementName -eq $NICName}

# Get current IP settings for that adapter
$currentSetting = $netAdapter.GetRelated('Msvm_GuestNetworkAdapterConfiguration')
#$Setting | Get-Member

# Define new settings from the current ones
$newSetting = @($currentSetting)[0]

# Address family values for settings IPv4 , IPv6 Or Boths 
# For IPv4:   ProtocolIFType = 4096; 
# For IPv6:   ProtocolIFType = 4097; 
# For IPv4/V6:ProtocolIFType = 4098; 

$newSetting.ProtocolIFType = 4096
$newSetting.DHCPEnabled    = $False
$newSetting.IPAddresses    = $IPAddress
$newSetting.Subnets        = $Subnet

if($DNSServers)
    {
        $newSetting.DNSServers     = $DNSServers
    }
else
    {
        $newSetting.DNSServers = @()
    }


if($DefaultGateway)
    {
        $newSetting.DefaultGateways= $DefaultGateway
    }
else
    {
      $newSetting.DefaultGateways= @()  
    }



#Apply the settings
$VSMS = $VM.GetRelated('Msvm_VirtualSystemManagementService') 
$Result = $VSMS.SetGuestNetworkAdapterConfiguration(
    $VM.Path,
    $newSetting.GetText(1)
    )
[wmi]$Result.Job
