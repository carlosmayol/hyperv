$clusterNodes = Get-ClusterNode | ? State -eq "Up" | Sort-Object Name | Select-Object -ExpandProperty Name 
Write-Host "Grabbing all witness client information..." 
$witnessClientObject = @(Get-SmbWitnessClient | %{ 
    $clientObj = @{}; 
    $clientObj['WitnessClient'] = $_; 
    $clientObj['OpenFileCount'] = @(Get-SmbOpenFile -ClientUserName "*$($_.ClientName)*").Count; 
    New-Object PSObject -Property $clientObj 
    } | sort-object OpenFileCount -Descending)
if($witnessClientObject.count -gt 0) 
{ 
    Write-Host "Found $($witnessClientObject.Count) objects" 
    $witnessClientObject | ft {$_.witnessclient.ClientName}, {$_.OpenFileCount} -a 
    Write-Host "Getting node distribution" 
    $distributionOfFiles = @($witnessClientObject | Group-Object {$_.WitnessClient.FileServerNodeName}) 
    $distributionObjects = @()
    foreach($distribution in $distributionOfFiles) 
    { 
        $distributionObject = @{} 
        $distributionObject['FileServerNodeName'] = $distribution.Name 
        $distributionObject['OpenFileCount'] = ($distribution.Group | Measure-Object OpenFileCount -Sum).Sum 
        $distributionObject['Clients'] = $distribution.Group 
        $distributionObjects += New-Object PSObject -Property $distributionObject 
    }
    #add in any cluster nodes that have 0 witness connections
    foreach($unusedClusterNode in ($clusterNodes |? { $name = $_; -not($distributionOfFiles |?{ $_.Name -match $name}) })) 
    { 
        $distributionObject = @{} 
        $distributionObject['FileServerNodeName'] = $unusedClusterNode 
        $distributionObject['OpenFileCount'] = 0 
        $distributionObject['Clients'] = @() 
        $distributionObjects += New-Object PSObject -Property $distributionObject 
    }
    #sort by the number of open files per server node
    $sortedDistribution = $distributionObjects | Sort-Object OpenFileCount -Descending 
    $sortedDistribution |%{ Write-Host "$($_.FileServerNodeName) - $($_.OpenFileCount)"} 
    Write-Host "" 
    Write-host "Distribution OpenFileCounts:" 
    Write-Host ""
    #Balance where needed
    for($step = 0; $step -lt $sortedDistribution.Count/2; ++$step) 
    { 
        #Get the difference between the largest and smallest file counts for this step 
        #divide by two so we don't flop a single connection back an forth on each run 
        $currentFileOpenVariance = [Math]::Ceiling(($sortedDistribution[$step].OpenFileCount - $sortedDistribution[-1 - $step].OpenFileCount)/2) 
        Write-Host "Variance for step $($step): $($currentFileOpenVariance)" 
        $moveTargets = @() 
        $moveOpenFiles = 0
        foreach($client in $sortedDistribution[$step].Clients) 
        { 
            if($client.OpenFileCount -gt 0) 
            { 
                $varianceAfterMove = ($moveOpenFiles + $client.OpenFileCount) 
                Write-Host "Checking $($varianceAfterMove) to be less than or equal to $($currentFileOpenVariance) to be a move target" 
                if($varianceAfterMove -le $currentFileOpenVariance) 
                { 
                    Write-Host "Client $($client.WitnessClient.ClientName) is a target for move" 
                    $moveTargets += $client.WitnessClient 
                    $moveOpenFiles += $client.OpenFileCount 
                } 
            } 
        }
        if($moveTargets.Count -gt 0) 
        { 
            foreach($moveTarget in $moveTargets) 
            { 
                Write-Host "Moving witness client $($moveTarget.ClientName) to SMB file server node $($sortedDistribution[-1 - $step].FileServerNodeName)" 
                Move-SmbWitnessClient -ClientName $moveTarget.ClientName ` 
                                      -DestinationNode $sortedDistribution[-1 - $step].FileServerNodeName ` 
                                      -Confirm:$false ` 
                                      -ErrorAction Continue | Out-Null 
            } 
        } 
        else 
        { 
            Write-Host "No move targets available" 
        } 
    } 
}
Write-Host "SMB Witness client connections should now be as balanced as possible"
