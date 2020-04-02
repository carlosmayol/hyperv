# Create cluster
New-Cluster -Name Cluster2 -Node ws2012clu-lab,ws2012clu-lab2 -StaticAddress 192.168.180.81 -IgnoreNetwork 192.168.210.0/24, 192.168.220.0/24 -Verbose

