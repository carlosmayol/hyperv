# intelligently set processor assignment for Virtual Machine Queue (VMQ)
# or Receive Side Scaling (RSS) in NIC Teams
 
Function
Set-NetAdapterAffinity
{
 
   #region Data
 
        [cmdletbinding()]
 
        Param(
            [parameter(
                Mandatory = $True
            )]
            [System.String]
            $ComputerName
        ,
            [parameter(
                Mandatory = $True
            )]
            [System.String]
            [ValidateSet(
                "VMQ",
                "RSS"
            )]
            $Mode
        )
 
   #endregion Data
 
   #region Code
 
        Write-Verbose -Message "Entering Set-NetAdapterAffinity for $ComputerName"
 
        $Module = Import-ModuleEx -Name "NetLbfo"
        $Module = Import-ModuleEx -Name "NetAdapter"
 
        $GetCimInstanceParam = @{
        
            ComputerName = $ComputerName
            ClassName    = "Win32_Processor"
            Verbose      = $False
        }
        $Processor       =  Get-CimInstance @GetCimInstanceParam
 
        $CoreTotal       = $Processor.Count * $Processor[0].NumberOfCores
        $HyperThreading  = $Processor[0].NumberOfLogicalProcessors /
                           $Processor[0].NumberOfCores
        $Team            =  Get-NetLbfoTeam -CimSession $ComputerName
 
        $Team | ForEach-Object -Process {
 
            $TeamCurrent     = $PSItem
            $TeamMember      = $TeamCurrent.Members
            $CoreStep        = $CoreTotal / $TeamMember.Count
            $CoreCurrent     = 0
            $NumaNodeStep    = $Processor.Count / $TeamMember.Count
            $NumaNodeCurrent = 0
    
            $TeamMember | Sort-Object | ForEach-Object -Process {
 
                $NicCurrentName = $PSItem
 
                $GetNetAdapterParam = @{
 
                    CimSession = $ComputerName
                    Name       = $NicCurrentName
                }
 
                Switch
                (
                    $Mode
                )
                {
                    "VMQ"
                    {
                        $NicCurrent = Get-NetAdapterVmq @GetNetAdapterParam
                    }
                    "RSS"
                    {
                        $NicCurrent = Get-NetAdapterRss @GetNetAdapterParam
                    }
                }
        
                If
                (
                    $CoreCurrent -eq 0
                )
                {
                
                  #  BaseProcessorNumber and MaxProcessorNumber
                  #  count Threads, not Cores
                    $BaseProcessorNumber = 1 * $HyperThreading
 
                  #  MaxProcessors counts Cores, not Threads
                    $MaxProcessors       = $CoreStep - $BaseProcessorNumber
                }
                Else
                {
 
                  #  BaseProcessorNumber and MaxProcessorNumber
                  #  count Threads, not Cores
                    $BaseProcessorNumber = $CoreCurrent * $HyperThreading
 
                  #  MaxProcessors counts Cores, not Threads
                    $MaxProcessors       = $CoreStep
                }
 
              #  BaseProcessorNumber and MaxProcessorNumber
              #  count Threads, not Cores
                $MaxProcessorNumber = ( $CoreCurrent + $CoreStep ) * $HyperThreading - 1
 
                $SetNetAdapterParam = @{
 
                    InputObject         = $NicCurrent
                    BaseProcessorNumber = $BaseProcessorNumber
                    MaxProcessorNumber  = $MaxProcessorNumber
                    MaxProcessors       = $MaxProcessors
                    NumaNode            = $NumaNodeCurrent
                    Enabled             = $True
                }
 
             <# $SetNetAdapterParam.GetEnumerator() | ForEach-Object -Process {
 
                    Write-Host -Object ($PSItem.Key + ": " + $PSItem.Value)
                } #>
 
                Switch
                (
                    $Mode
                )
                {
                    "VMQ"
                    {
                        Set-NetAdapterVmq @SetNetAdapterParam
                    }
                    "RSS"
                    {
                        Set-NetAdapterRss @SetNetAdapterParam
                    }
                }                
 
                $CoreCurrent     = $CoreCurrent     + $CoreStep
                $NumaNodeCurrent = $NumaNodeCurrent + $NumaNodeStep
            }
        }
 
        Write-Verbose -Message "Exiting  Set-NetAdapterAffinity for $ComputerName"
 
   #endregion Code
 
}