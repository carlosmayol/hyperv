<#
	Hyper-V-KVP-Host Module

	Place on Hyper-V hosts to send and receive KVP data to and from guests.
	Written by Eric Siron
	(c) 2016 Altaro Software
#>

$KVPHostVirtualizationNamespace = 'root\virtualization\v2'

function New-VMNameComputerPair
{
	<#
	.SYNOPSIS
		Accepts a single virtual machine name and computer name and combines them into an object.
		Not exported; utility function that exists because PowerShell 4 has no capabilities that enable method inheritance.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	param(
		[Parameter(Mandatory=$true)][String]$VMName,
		[Parameter(Mandatory=$true)][String]$ComputerName
	)
	Write-Verbose -Message 'Creating custom VMNameComputerPair object...'
	$VMNameComputerPair = New-Object -TypeName PSObject
	Add-Member -InputObject $VMNameComputerPair -MemberType NoteProperty -Name VMName -Value $VMName
	Add-Member -InputObject $VMNameComputerPair -MemberType NoteProperty -Name ComputerName -Value $ComputerName
	$VMNameComputerPair
}

function Get-VMNameComputerPairsFromStrings
{
	<#
	.SYNOPSIS
		Accepts an array of virtual machine names and a computer name and combines them into a merged object array.
		Not exported; utility function that exists because PowerShell 4 has no capabilities that enable method inheritance.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	param(
		[Parameter(Mandatory=$true)][String[]]$VMNames,
		[Parameter(Mandatory=$true)][String]$ComputerName
	)
	foreach($VMName in $VMNames)
	{
		Write-Verbose -Message ('Requesting custom VMNameComputerPair object for virtual machine {0} on {1}...' -f $VMName, $ComputerName)
		New-VMNameComputerPair -VMName $VMName -ComputerName $ComputerName
	}
}

function Get-VMNameComputerPairsFromVMs
{
	<#
	.SYNOPSIS
		Accepts an array of virtual macines and coverts them into an array of virtual machine names and associated computer names.
		Not exported; utility function that exists because PowerShell 4 has no capabilities that enable method inheritance.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	param(
		[Parameter(Mandatory=$true)][Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM
	)

	$VMSet = @()
	foreach ($VMObject in $VM)
	{
		Write-Verbose -Message ('Requesting custom VMNameComputerPair object for virtual machine {0} on {1}...' -f $VMObject.Name, $VMObject.ComputerName)
		$VMSet += New-VMNameComputerPair -VMName $VMObject.Name -ComputerName $VMObject.ComputerName
	}
	$VMSet
}


function Get-VMWmiObject
{
	<#
	.SYNOPSIS
		Retrieves a WMI object that represents a virtual machine.
	.DESCRIPTION
		Given a virtual machine object or name, returns the relevant WMI object.
	.PARAMETER VMName
		The name of a virtual machine. Cannot be used with VM.
	.PARAMETER VM
		A virtual machine object. Cannot be used with VMName or ComputerName
	.PARAMETER ComputerName
		The host that owns the virtual machine. If not specified, the local host will be assumed.
	.OUTPUTS
		System.Management.ManagementObject
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param(
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=1)][String]$VMName,
		[Parameter(Mandatory=$true, ParameterSetName='ByVM', Position=1)][Microsoft.HyperV.PowerShell.VirtualMachine]$VM,
		[Parameter(ParameterSetName='ByName', Position=2)][String]$ComputerName='.'
	)

	begin
	{
		if($PSCmdlet.ParameterSetName -eq 'ByVM')
		{
			$VMName = $VM.Name
			$ComputerName = $VM.Name
		}
	}

	process
	{
		Write-Verbose -Message ('Requesting WMI object that represents VM {0} on {1}' -f $VMName, $ComputerName)
		$VMWMIObject = Get-WmiObject -ComputerName $ComputerName -Namespace $KVPHostVirtualizationNamespace -Class Msvm_ComputerSystem -Filter "ElementName = '$VMName'"
		if(-not($VMWMIObject))
		{
			Write-Error -Message ('VM {0} not found on computer {1}' -f $VMName, $ComputerName)
		}
		else
		{
			$VMWMIObject
		}
	}
}

function Get-VMMS
{
	<#
	.SYNOPSIS
		Retrieves the WMI interface for the Hyper-V Virtual Machine Management Service (VMMS). Not exported.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	param
	(
		[Parameter()][String]$ComputerName='.'
	)
	process
	{
		Write-Verbose -Message ('Requesting access to Hyper-V Virtual Machine Management Service on {0} via WMI' -f $ComputerName)
		Get-WmiObject -ComputerName $ComputerName -Namespace $KVPHostVirtualizationNamespace -Class Msvm_VirtualSystemManagementService
	}
}

function Process-WMIJob
{
	<#
	.SYNOPSIS
		The KVP functions of VMMS return a WMI job. This function processes the jobs and determines the result.
		Not exported.
	.NOTES
		Most of this function was written by Taylor Brown.
		Source: http://blogs.msdn.com/b/taylorb/archive/2008/06/18/hyper-v-wmi-rich-error-messages-for-non-zero-returnvalue-no-more-32773-32768-32700.aspx
		Modifications were made for parameter/variable naming clarity and to streamline for use in this KVP project.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	param
	(
		[Parameter(ValueFromPipeline=$true)][System.Management.ManagementBaseObject]$WmiResponse,
		[Parameter()][String]$WmiClassPath = $null,
		[Parameter()][String]$MethodName = $null,
		[Parameter()][String]$VMName,
		[Parameter()][String]$ComputerName
	)
	
	process
	{
		$ErrorCode = 0

		if($WmiResponse.ReturnValue -eq 4096)
		{
			$Job = [WMI]$WmiResponse.Job

			while ($Job.JobState -eq 4)
			{
				
				Write-Progress -Activity ('Modifying KVPs on VM {0} on {1}' -f $VMName, $ComputerName) -Status ('{0}% Complete' -f $Job.PercentComplete) -PercentComplete $Job.PercentComplete
				Start-Sleep -Milliseconds 100
				$Job.PSBase.Get()
			}

			if($Job.JobState -ne 7)
			{
				if ($Job.ErrorDescription -ne "")
				{
					throw $Job.ErrorDescription
				}
				else
				{
					$ErrorCode = $Job.ErrorCode
				}
				Write-Progress $Job.Caption "Completed" -Completed $true
			}
		}
		elseif ($WmiResponse.ReturnValue -ne 0)
		{
			$ErrorCode = $WmiResponse.ReturnValue
		}

		if($ErrorCode -ne 0)
		{
			if($WmiClassPath -and $MethodName)
			{
				$PSWmiClass = [WmiClass]$WmiClassPath
				$PSWmiClass.PSBase.Options.UseAmendedQualifiers = $true
				$MethodQualifiers = $PSWmiClass.PSBase.Methods[$MethodName].Qualifiers
				$IndexOfError = [System.Array]::IndexOf($MethodQualifiers["ValueMap"].Value, [String]$ErrorCode)
				if($IndexOfError -ne "-1")
				{
					'Error Code: {0}, Method: {1}, Error: {2}' -f $ErrorCode, $MethodName, $MethodQualifiers["Values"].Value[$IndexOfError]
				}
				else
				{
					'Error Code: {0}, Method: {1}, Error: Message Not Found' -f $ErrorCode, $MethodName
				}
			}
		}
	}
}


function Get-Kvp
{
	<#
	.SYNOPSIS
		Gets host-to-guest or guest-to-host KVP.
		Not exported; utility function that exists because PowerShell 4 has no capabilities that enable method inheritance.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param
	(
		[Parameter(Mandatory=$true)][System.Management.ManagementObject]$VMWMIObject,
		[Parameter()][String[]]$Key,
		[Parameter()][String][ValidateSet('HostToGuest', 'GuestToHost', 'GuestToHostIntrinsic')]$KVPSet
		)

	begin
	{
		$MSVM_CS_ENABLED_STATE_RUNNING = 2
	}

	process
	{
		$VMWMIObject.Get()
		if ($VMWMIObject.EnabledState -eq $MSVM_CS_ENABLED_STATE_RUNNING)
		{
			$Keys = @()
			if($Key.Count)
			{
				foreach($KeyName in $Key)
				{
					$Keys += $KeyName.ToLower()
				}
			}

			$KVPs = @()

			Write-Verbose -Message ('Retrieving root KVP element from {0} on {1}...' -f $VMWMIObject.ElementName, $VMWMIObject.PSComputerName)
			$KVPRootObject = $VMWmiObject.GetRelated('Msvm_KvpExchangeComponent')
			switch($KVPSet)
			{
				'HostToGuest' {
					Write-Verbose -Message ('Retrieving host-to-guest KVPs from {0} on {1}...' -f $VMWMIObject.ElementName, $VMWMIObject.PSComputerName)
					$XMLKVPItems = $KVPRootObject.GetRelated('Msvm_KvpExchangeComponentSettingData').HostExchangeItems
				}
				'GuestToHost' {
					Write-Verbose -Message ('Retrieving guest-to-host KVPs from {0} on {1}...' -f $VMWMIObject.ElementName, $VMWMIObject.PSComputerName)
					$XMLKVPItems = $KVPRootObject.GuestExchangeItems
				}
				'GuestToHostIntrinsic' {
					Write-Verbose -Message ('Retrieving intrinsic guest-to-host KVPs from {0} on {1}...' -f $VMWMIObject.ElementName, $VMWMIObject.PSComputerName)
					$XMLKVPItems = $KVPRootObject.GuestIntrinsicExchangeItems
				}
			}

			foreach ($XMLKVPItem in $XMLKVPItems)
			{
				Write-Verbose -Message ('Extracting key...')
				$KVPKey = ([XML]$XMLKVPItem).SelectSingleNode("/INSTANCE/PROPERTY[@NAME='Name']/VALUE/child::text()").Value
				if($Key.Count -and -not ($Keys.Contains(($KVPKey.ToLower()).Trim())))
				{
					Write-Verbose -Message ('This key ({0} is not in the explicit search set, skipping.' -f $KVPKey)
					continue
				}
				Write-Verbose -Message ('Retrieving value for {0}...' -f $KVPKey)
				$KVPValue = ([XML]$XMLKVPItem).SelectSingleNode("/INSTANCE/PROPERTY[@NAME='Data']/VALUE/child::text()").Value
				Write-Verbose -Message ('Building output object...')
				$KVPItem = New-Object -TypeName PSObject
				Add-Member -InputObject $KVPItem -MemberType NoteProperty -Name 'VMName' -Value $VMWMIObject.ElementName
				Add-Member -InputObject $KVPItem -MemberType NoteProperty -Name 'Key' -Value $KVPKey
				Add-Member -InputObject $KVPItem -MemberType NoteProperty -Name 'Value' -Value $KVPValue
				$KVPs += $KVPItem
			}
			$KVPs
		}
		else
		{
			Write-Warning -Message ('VM {0} on host {1} is not running. KVPs cannot be retrieved.' -f $VMWMIObject.ElementName, $VMWMIObject.PSComputerName)
		}
	}
}

function Get-VMKvpGuestToHost
{
	<#
	.SYNOPSIS
		Retrieves one or more guest-to-host KVPs from a specific virtual machine.
	.DESCRIPTION
		Retrieves one or more guest-to-host KVPs from a specific virtual machine.
	.PARAMETER VMName
		The name of the virtual machine whose KVPs are to be retrieved. Cannot be used with VM.
	.PARAMETER VM
		The virtual machine object whose KVPs are to be retrieved. Cannot be used with VMName or ComputerName.
	.PARAMETER ComputerName
		The name of the Hyper-V host that owns the virtual machine. If not specified, the local host will be used.
	.PARAMETER Key
		One or more case-insensitive key names.
		If this parameter is specified, only KVPs with matching key names will be returned.
		If this parameter is not specified, all KVPs will be returned.
	.OUTPUTS
		Zero or more custom objects with properties "VMName", "Key", and "Value"
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param
	(
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=1)][String[]]$VMName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='ByVM', Position=1)][Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
		[Parameter(ParameterSetName='ByName', Position=2)][Parameter(ParameterSetName='ByVM')][String[]]$Key,
		[Parameter(ParameterSetName='ByName')][String]$ComputerName='.'
	)

	begin
	{
		if($PSCmdlet.ParameterSetName -eq 'ByName')
		{
			$VMSet = Get-VMNameComputerPairsFromStrings -VMNames $VMName -ComputerName $ComputerName
		}
	}
	 
	process
	{
		if($PSCmdlet.ParameterSetName -eq 'ByVM')
		{
			$VMSet = Get-VMNameComputerPairsFromVMs -VM $VM
		}

		foreach($VMNameComputerPair in $VMSet)
		{
			$VMWMIObject = Get-VMWmiObject -VMName $VMNameComputerPair.VMName -ComputerName $VMNameComputerPair.ComputerName
		
			if($VMWMIObject)
			{
				Get-Kvp -VMWMIObject $VMWmiObject -Key $Key -KVPSet GuestToHost
			}
		}
	}
}

function Get-VMKvpGuestToHostIntrinsic
{
	<#
	.SYNOPSIS
		Retrieves one or more of the intrinsic guest-to-host KVPs from a specific virtual machine.
	.DESCRIPTION
		Retrieves one or more of the intrinsic guest-to-host KVPs from a specific virtual machine.
		These values are automatically generated by the Data Exchange service within the guest and contain information about the guest operating system.
	.PARAMETER VMName
		The name of the virtual machine whose KVPs are to be retrieved. Cannot be used with VM.
	.PARAMETER VM
		The virtual machine object whose KVPs are to be retrieved. Cannot be used with VMName or ComputerName.
	.PARAMETER ComputerName
		The name of the Hyper-V host that owns the virtual machine. If not specified, the local host will be used.
	.PARAMETER Key
		One or more case-insensitive key names.
		If this parameter is specified, only KVPs with matching key names will be returned.
		If this parameter is not specified, all KVPs will be returned.
	.OUTPUTS
		Zero or more custom objects with properties "VMName", "Key", and "Value"
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param
	(
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=1)][String]$VMName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='ByVM', Position=1)][Microsoft.HyperV.PowerShell.VirtualMachine]$VM,
		[Parameter(ParameterSetName='ByName', Position=2)][Parameter(ParameterSetName='ByVM')][String[]]$Key,
		[Parameter(ParameterSetName='ByName')][String]$ComputerName='.'
	)

	begin
	{
		if($PSCmdlet.ParameterSetName -eq 'ByName')
		{
			$VMSet = Get-VMNameComputerPairsFromStrings -VMNames $VMName -ComputerName $ComputerName
		}
	}
	 
	process
	{
		if($PSCmdlet.ParameterSetName -eq 'ByVM')
		{
			$VMSet = Get-VMNameComputerPairsFromVMs -VM $VM
		}

		foreach($VMNameComputerPair in $VMSet)
		{
			$VMWMIObject = Get-VMWmiObject -VMName $VMNameComputerPair.VMName -ComputerName $VMNameComputerPair.ComputerName

			if($VMWMIObject)
			{
				Get-Kvp -VMWMIObject $VMWmiObject -Key $Key -KVPSet GuestToHostIntrinsic
			}
		}
	}
}

function Get-VMKvpHostToGuest
{
	<#
	.SYNOPSIS
		Retrieves one or more host-to-guest KVPs from a specific virtual machine.
	.DESCRIPTION
		Retrieves one or more host-to-guest KVPs from a specific virtual machine.
	.PARAMETER VMName
		The name of the virtual machine whose KVPs are to be retrieved. Cannot be used with VM.
	.PARAMETER VM
		The virtual machine object whose KVPs are to be retrieved. Cannot be used with VMName or ComputerName.
	.PARAMETER ComputerName
		The name of the Hyper-V host that owns the virtual machine. If not specified, the local host will be used.
	.PARAMETER Key
		One or more case-insensitive key names.
		If this parameter is specified, only KVPs with matching key names will be returned.
		If this parameter is not specified, all KVPs will be returned.
	.OUTPUTS
		Zero or more custom objects with properties "VMName, "Key", and "Value"
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param
	(
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=1)][String[]]$VMName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='ByVM', Position=1)][Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
		[Parameter(ParameterSetName='ByName', Position=2)][Parameter(ParameterSetName='ByVM')][String[]]$Key,
		[Parameter(ParameterSetName='ByName')][String]$ComputerName='.'
	)

	begin
	{
		if($PSCmdlet.ParameterSetName -eq 'ByName')
		{
			$VMSet = Get-VMNameComputerPairsFromStrings -VMNames $VMName -ComputerName $ComputerName
		}
	}
	 
	process
	{
		if($PSCmdlet.ParameterSetName -eq 'ByVM')
		{
			$VMSet = Get-VMNameComputerPairsFromVMs -VM $VM
		}

		foreach($VMNameComputerPair in $VMSet)
		{
			$VMWMIObject = Get-VMWmiObject -VMName $VMNameComputerPair.VMName -ComputerName $VMNameComputerPair.ComputerName

			if($VMWMIObject)
			{
				Get-Kvp -VMWMIObject $VMWmiObject -Key $Key -KVPSet HostToGuest
			}
		}
	}
}

function Send-VMKvpHostToGuest
{
	<#
	.SYNOPSIS
		Sends a KVP to a virtual machine.
	.DESCRIPTION
		Sends a KVP from the specified host to the specified guest. If the key does not exist, it will be created.
	.PARAMETER VMName
		The name of the virtual machine where the KVP is to be created or modified. Cannot be used with VM.
	.PARAMETER VM
		The virtual machine object where the KVP is to be created or modified. Cannot be used with VMName or ComputerName.
	.PARAMETER ComputerName
		The name of the Hyper-V host that owns the virtual machine. If not specified, the local host will be used.
	.PARAMETER Key
		Name of the key to be used. If it does not exist, it will be created.
	.PARAMETER Value
		Value to be stored in the KVP data sent to the virtual machine. If not specified, the value will be empty.
	.OUTPUTS
		NONE
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param
	(
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=1)][String[]]$VMName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='ByVM', Position=1)][Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=2)][Parameter(Mandatory=$true, ParameterSetName='ByVM')][String[]]$Key,
		[Parameter(Position=3)][String]$Value='',
		[Parameter(ParameterSetName='ByName')][String]$ComputerName='.'
	)

	begin
	{
		if($PSCmdlet.ParameterSetName -eq 'ByName')
		{
			$VMSet = Get-VMNameComputerPairsFromStrings -VMNames $VMName -ComputerName $ComputerName
		}
	}
	 
	process
	{
		if($PSCmdlet.ParameterSetName -eq 'ByVM')
		{
			$VMSet = Get-VMNameComputerPairsFromVMs -VM $VM
		}

		foreach($VMNameComputerPair in $VMSet)
		{
			$VMWMIObject = Get-VMWmiObject -VMName $VMNameComputerPair.VMName -ComputerName $VMNameComputerPair.ComputerName
			$VMMS = Get-VMMS -ComputerName $VMWMIObject.PSComputerName
			$KVPDataItem = ([wmiclass]"\$($VMMS.ClassPath.Server)$($VMMS.ClassPath.NamespacePath):Msvm_KvpExchangeDataItem").CreateInstance()
			$KVPDataItem.Name = $Key
			$KVPDataItem.Data = $Value
			$KVPDataItem.Source = 0

			$KVPTransmitJob = $VMMS.ModifyKvpItems($VMWmiObject, $KVPDataItem.GetText(1))
			try
			{
				$WMIJobResult = Process-WMIJob -WmiResponse $KVPTransmitJob -WmiClassPath $VMMS.ClassPath -MethodName 'ModifyKvpItems' -VMName $VMWMIObject.ElementName -ComputerName $VMWMIObject.PSComputerName
			}
			catch
			{
				$KVPTransmitJob = $VMMS.AddKvpItems($VMWmiObject, $KVPDataItem.GetText(1))
				$WMIJobResult = Process-WMIJob -WmiResponse $KVPTransmitJob -WmiClassPath $VMMS.ClassPath -MethodName 'AddKvpItems' -VMName $VMWMIObject.ElementName -ComputerName $VMWMIObject.PSComputerName
			}
			if($WMIJobResult) # return will be empty if everything is OK
			{
				Write-Error -Message ('Setting key {0} to {1} from VM {2} on {3} failed: {4}' -f $Key, $Value, $VMWMIObject.ElementName, $VMWMIObject.PSComputerName, $WMIJobResult)
			}
		}
	}
}

function Remove-VMKvpHostToGuest
{
	<#
	.SYNOPSIS
		Removes a host-to-guest KVP from a virtual machine.
	.DESCRIPTION
		Removes a host-to-guest KVP from a virtual machine.
	.PARAMETER VMName
		The name of the virtual machine whose KVP is to be deleted. Cannot be used with VM.
	.PARAMETER VM
		The virtual machine object whose KVP is to be deleted. Cannot be used with VMName or ComputerName.
	.PARAMETER ComputerName
		The name of the Hyper-V host that owns the virtual machine. If not specified, the local host will be used.
	.PARAMETER Key
		Name of the key to be used. If it does not exist, it will be created.
	.PARAMETER Value
		Value to be stored in the KVP data sent to the virtual machine. If not specified, the value will be empty.
	.OUTPUTS
		NONE
	.NOTES
		If the specified KVP does not exist, that alone will not cause the function to return $FALSE.
	#>
	#requires -Version 4
	#requires -RunAsAdministrator
	#requires -Modules Hyper-V

	[CmdletBinding(DefaultParameterSetName='ByName')]
	param
	(
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=1)][String[]]$VMName,
		[Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='ByVM', Position=1)][Microsoft.HyperV.PowerShell.VirtualMachine[]]$VM,
		[Parameter(Mandatory=$true, ParameterSetName='ByName', Position=2)][Parameter(Mandatory=$true, ParameterSetName='ByVM')][String[]]$Key,
		[Parameter(ParameterSetName='ByName')][String]$ComputerName='.'
	)

	begin
	{
		if($PSCmdlet.ParameterSetName -eq 'ByName')
		{
			$VMSet = Get-VMNameComputerPairsFromStrings -VMNames $VMName -ComputerName $ComputerName
		}
	}
	 
	process
	{
		if($PSCmdlet.ParameterSetName -eq 'ByVM')
		{
			$VMSet = Get-VMNameComputerPairsFromVMs -VM $VM
		}

		foreach($VMNameComputerPair in $VMSet)
		{
			$VMWMIObject = Get-VMWmiObject -VMName $VMNameComputerPair.VMName -ComputerName $VMNameComputerPair.ComputerName
			if($VMWMIObject)
			{
				$VMMS = Get-VMMS -ComputerName $VMWMIObject.PSComputerName

				$KVPDataItem = ([wmiclass]"\$($VMMS.ClassPath.Server)$($VMMS.ClassPath.NamespacePath):Msvm_KvpExchangeDataItem").CreateInstance()
				$KVPDataItem.Name = $Key
				$KVPDataItem.Data = [String]::Empty
				$KVPDataItem.Source = 0

				$KVPRemoveJob = $VMMS.RemoveKvpItems($VMWMIObject, $KVPDataItem.GetText(1))
				$WMIJobResult = Process-WMIJob -WmiResponse $KVPRemoveJob -WmiClassPath $VMMS.ClassPath -MethodName 'RemoveKvpItems' -VMName $VMWMIObject.ElementName -ComputerName $VMWMIObject.PSComputerName

				if($WMIJobResult) # return will be empty if everything is OK
				{
					Write-Error -Message ('Removal of {0} from {1} on {2} failed: {3}' -f $Key, $VMWMIObject.ElementName, $VMWMIObject.PSComputerName, $WMIJobResult)
				}
			}
		}
	}
}