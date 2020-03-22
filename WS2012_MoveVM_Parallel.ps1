Workflow Invoke-ParallelLiveMigrate
{
 Param (
[parameter(Mandatory=$true)][String[]] $VMList,
[parameter(Mandatory=$true)][String] $SourceHost,
[parameter(Mandatory=$true)][String] $DestHost
# [parameter(Mandatory=$true)][String] $DestPath
)
ForEach -Parallel ($VM in $VMList) 
{
Move-VM -computername $sourceHost -Name $VM -DestinationHost $DestHost -IncludeStorage
}
}

# Use: 
#Invoke-ParallelLiveMigrate -VMList vmtest1,vmtest2 -SourceHost ws2012clu-lab -DestHost ws2012clu-lab2
Invoke-ParallelLiveMigrate -VMList vmtest1,vmtest2 -SourceHost ws2012clu-lab2 -DestHost ws2012clu-lab
