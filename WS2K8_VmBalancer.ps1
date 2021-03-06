#
# VmBalancer.ps1 - A powershell script which balances the load of Hyper-V VMs across all cluster nodes 
#
# Environment: Windows Server 2008 R2, Hyper-V, Failover cluster
#
# How it works: 
#  All cluster nodes are checked for their virtual to logical processor ratio.
#  Then the average of this values is value is calculated for the entire cluster
#  Then the 2 nodes with the maximum and minimum distance to this average are calculated
#  If the minimum distance is greater then the maximum, the least loaded host is very likely capable
#  to take a VM from the maximum loaded host. So the script does LiveMigrate -one- VM per run  
#
# Notes:
#  The script does run standalone, if you set Set-ExecutionPolicy correctly. I run it as a Scheduled Task
#  every 30 minutes on each cluster node. The script checks if it runs on the one node currently owning the 
#  Cluster Group, to ensure it is not run simulateneously on multiple nodes. 
#  on Each run, only one VM might be moved, to allow for one LiveMigration at a time
#  When a VM is moved, an event from VM Balancer is written to the Application Event log.
#  
#
# Thoughts:
#  Once you reboot a cluster node, by default, the running VM's are migrated to other nodes. When the node comes
#  back online, VM's are not moved back. You may set Prefered Owners and define a failback policy, but this is 
#  rather static. In future, the script might make use of VMM's star rating for best placement, but for now it should also run without VMM
#
#  The recommended virtual to logical processer ratio is 8:1. Courtesy of algorithm
#  See: http://blogs.msdn.com/b/virtual_pc_guy/archive/2010/08/13/using-powershell-to-find-the-virtual-processor-to-logical-processor-ratio-of-hyper-v.aspx
#  It might happen that the destination node is not able to take the VM as it has not enough memory. This should be
#  covered by LiveMigration checks and the VM is then not moved.
# 
# Warning:
#  This script had limited testing, on my 2 identical node cluster. Use at own risk after your own testing.
#
#
# robertvi at microsoft.com 
# 
# v1.0 101007
#
#
#
 
Import-Module FailoverClusters  # load cluster cmdlet
 
$averageload=0
$numberofnodes=0
$maxload = 0
$minload = 1000
$maxloadedhost = 'undefined'
$minloadedhost = 'undefined'
 

#ensure we run on one node only
$master = Get-ClusterGroup |  ?{ $_.Name -like "Cluster Group" }
$thishost = Get-WmiObject -class win32_computersystem
 
$master = $master.OwnerNode.Name.ToLower()
$thishost = $thishost.Name.ToLower()
 
Write-Host "Cluster Group owner:" $master "Script Host:" $thishost "<"
 
if ( $master -ne $thishost)
{
 Write-Host "Exiting Script as it is not run on the node that owns the Cluster Group"
 exit
}
 
 
 
# Get all nodes
$nodes = get-clusternode
 
foreach ($node in $nodes)
{
 
 $Hostinfo = Get-WmiObject -class win32_computersystem -computername $node
 Write-Host "Host " $Hostinfo.Name
 $load = (@(gwmi -ns root\virtualization MSVM_Processor -computername $node).count / (@(gwmi Win32_Processor -computername $node) | measure -p NumberOfLogicalProcessors -sum).Sum)  
 Write-Host "Load " $load
 
 if ($load -ge $maxload) 
 {
  $maxload = $load
  $maxloadedhost = $node
 }
 
 if ($load -le $minload) 
 {
  $minload = $load
  $minloadedhost = $node
 }
 
 
 
 $averageload += $load
 $numberofnodes += 1
 
}
 
$averageload /= $numberofnodes
Write-Host "Average Load " $averageload
Write-Host "Max Load " $maxload
Write-Host "Min Load " $minload
 
# 
# Now if the maximum loaded host - minimum loaded host is still above average, push a VM from maximum to minimum.
#
 

if (($maxload - $averageload) -gt $minload) #is maxload distance to average greater then minloads distance?
{
 Write-Host "Push a VM from" $maxloadedhost "to " $minloadedhost
 
 #find a running VM on $maxloadedhost and move to $minloadedhost
 
 $VMGroups = Get-ClusterNode $maxloadedhost.Name | Get-ClusterGroup | ?{ $_ | Get-ClusterResource | ?{ $_.ResourceType -like "Virtual Machine" } }
 

 foreach ($vm in $VMGroups)
 {
 
    if ($vm.State -eq 'Online')
    { 
         Write-Host "VM Group to mmigrate" $vm.name
            

  # This is our best candidate. May still not possible to move when destination memory not sufficent. 
  # LiveMigration will determine this and abort the migrate.
  # if Quick Migration should be used: Move-ClusterGroup $vm -Node $minloadedhost
 
  $evtinfo = "Moving " + $vm + " to Node " + $minloadedhost + " Avg load " +$averageload + " maxload " + $maxload + " minload " + $minload
  $evt=new-object System.Diagnostics.EventLog("Application")
  $evt.Source="VM Balancer"
  $infoevent=[System.Diagnostics.EventLogEntryType]::Information
  $evt.WriteEntry($evtinfo,$infoevent,666)
 

          Move-ClusterVirtualMachineRole $vm -Node $minloadedhost -Wait 0
 
  break
             
    } 
 

 }
 

}
else 
{
  Write-Host "No Balancing needed"
} 