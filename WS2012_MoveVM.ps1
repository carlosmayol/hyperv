#Mome VMs Share nothing
move-vm -Name vmtest1 -DestinationHost ws2012clu-lab2 -IncludeStorage -Verbose
move-vm -Name vmtest2 -DestinationHost ws2012clu-lab2 -IncludeStorage -Verbose

#from other host
#Invoke-Command -ComputerName ws2012clu-lab2 -ScriptBlock {move-vm vmtest3 -IncludeStorage -Verbose -DestinationHost ws2012clu-lab}
