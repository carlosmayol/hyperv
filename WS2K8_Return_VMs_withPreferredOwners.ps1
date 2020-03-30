ImportSystemModules 

#clustername ophalen 
[string]$cluster = Get-Cluster 

#clusternodes ophalen 
$ClusterNodes = Get-ClusterNode 


foreach ( $clusternode in $clusternodes ) 

{ 
[string]$clusternode = $clusternode 

  ## Get all the VMs in the Cluster on the Other Node 
  $VMGroups = Get-ClusterNode $clusternode | Get-ClusterGroup | ?{ $_ | Get-ClusterResource | ?{ $_.ResourceType -like "Virtual Machine" } } 
        foreach ( $VMGroup in $VMGroups ) 
        { 
                                        write-host "*****************************" 
          write-host "VM : $VMGroup" 
           
          $O = 0 
          ## Get the Preferred Owner of the VM 
          $colItems = Get-ClusterOwnerNode -Cluster $cluster -Group $VMGroup 
           
          [string]$strONodes = $colItems.OwnerNodes 

          foreach ($ONode in $colItems.OwnerNodes) 
          {               
                 
          $O++ 
          $DoMigrate = "" 
          } 
            ## If there is more than one Preferred Owner, do not migrate 
            if ($O -gt 1) 
            { 
              write-host 
              write-host "$VMGroup has more than one Preferred Node: $strONodes" 
              write-host 
              write-host "$VMGroup will not be migrated..." 
              write-host "If you want $VMGroup to have only one Preferred Node, uncheck all but the one Node" 
              $DoMigrate = "No" 
            } 
            ## If there is only one Preferred owner, grab the Node Name 
            elseif ($O -eq 1) 
            { 
             
            $DoMigrate = "Yes" 
            [string]$pf = $colItems.OwnerNodes -Replace " ", "" 
             
            } 

          [string]$currentVM = $VMGroup 
           
          $Currentowner = Get-ClusterGroup -name $currentVM 
           
          $Currentowner = $Currentowner.ownernode 
           
          [string]$strCurrentOwner = $Currentowner 
           
          ## Check the Node Status 
          $nodestate = (get-clusternode -Name $pf) 
                 
          $nodestate = $nodestate.State 
                   
          [string]$strnodestate = $nodestate 
           
          ## If the Current Owner is the Preferred, there is nothing to do. 
          if ($strCurrentOwner -eq $pf) 
          { 
            write-host 
            write-host "$VMGroup is on $Currentowner and will stay on $pf..." 
            write-host 
          } 
           
          ## If the Current Owner is not the Preferred Owner, and the Preferred Owner is up, Live Migrate it back to the Preferred Owner. 
          If ( $strCurrentOwner -ne $pf ) 
          { 
            write-host "$VMGroup is on $Currentowner but should be on $pf..." 
            write-host 
            If ($strnodestate -eq "Up" -and $DoMigrate -eq "Yes") 
            { 
            write-host 
            write-host "The Node $pf is Up" 
            write-host 
            write-host "Live Migrate $VMGroup to Node $pf" 
            write-host 
            Move-ClusterVirtualMachineRole $VMGroup -Node $pf 
            write-host 
            write-host "*****************************" 
            } 
          } 
         
        } 
  } 


----------------------------------------end script snip ----------------------------------------------------------------------------------
