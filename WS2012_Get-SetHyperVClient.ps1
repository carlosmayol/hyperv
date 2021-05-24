function Get-HVClientSettings
{
    $path = "$env:APPDATA\Microsoft\Windows\Hyper-V\Client\1.0\clientsettings.config"
    if(Test-Path $path)
    {
        [xml]$ClientSettings = Get-Content $path
        $settings = $ClientSettings.configuration.'Microsoft.Virtualization.Client.ClientVirtualizationSettings'
        $settings.setting
    }
    else
    {
        Write-Error "'$path' was not found"
    }
}

#Get-HVClientSettings | Select-Object Name,Value

function Set-HVClientSettings
{
    [CmdletBinding()]
    param(
        [ValidateSet('Remote','Local','FullScreen')]
        [string]$ConnectKeyboardOption,

        [ValidateSet('LeftArrow','RightArrow','Space','Shift')]
        [string]$ReleaseKey,

        [bool]$UseEnhancedMode,

        [bool]$UseAllMonitors,

        [switch]$RestartClient
    )

    $requiredVersion = $PSVersionTable.BuildVersion -lt '6.3.9600'
    $path = "$env:APPDATA\Microsoft\Windows\Hyper-V\Client\1.0\clientsettings.config"

    if(Test-Path $path)
    {
        [xml]$ClientSettings = Get-Content $path
        $settings = $ClientSettings.configuration.'Microsoft.Virtualization.Client.ClientVirtualizationSettings'

        if($ConnectKeyboardOption)
        {
            $settings.SelectSingleNode("//setting[@name='VMConnectKeyboardOption']").value = $ConnectKeyboardOption
        }

        if($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('UseEnhancedMode'))
        {
            if($requiredVersion)
            {
                Write-Warning "'UseEnhancedMode' is available only in Windows 8.1/Windows server 2012 R2 and higher."
            }
            else
            {
                $settings.SelectSingleNode("//setting[@name='VMConnectUseEnhancedMode']").value = "$UseEnhancedMode"
            }
        }

        if($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('UseAllMonitors'))
        {
            if($requiredVersion)
            {
                Write-Warning "'UseAllMonitors' is available only in Windows 8.1/Windows server 2012 R2 and higher."
            }
            else
            {
                $settings.SelectSingleNode("//setting[@name='UseAllMonitors']").value = "$UseAllMonitors"
            }
        }

        if($ReleaseKey)
        {
            $settings.SelectSingleNode("//setting[@name='VMConnectReleaseKey']").value = $ReleaseKey -replace 'arrow'
        }

        $ClientSettings.Save($path)

        if($RestartClient)
        {
            Get-Process | Where-Object MainWindowTitle -eq 'Hyper-V Manager' | Stop-Process -Force

            if(Test-Path "$env:ProgramFiles\Hyper-V\virtmgmt.msc")
            {
                # 2008 R2 location
                & "$env:ProgramFiles\Hyper-V\virtmgmt.msc"
            }
            else
            {
                virtmgmt.msc
            }
        }
    }
    else
    {
        Write-Error "'$path' was not found"
    }
}

#Set-HVClientSettings -UseEnhancedMode $true
#Set-HVClientSettings -UseEnhancedMode $false