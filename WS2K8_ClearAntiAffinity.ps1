# Created version 0.1 by Carlos Mayol
# El equipo que ejecuta el script debe tener las RSAT para Failovecluster instaladas.

# "Use: .\ClearAffinity.ps1 CLUSTERNAME"

Set-StrictMode -version Latest

Clear-host

import-module failoverclusters

#STARTING SCRIPT

#Almacenamos los resGroups del cluser que no sean CoreResources
$Resgroups = Get-ClusterGroup -cluster $args[0] | where-object {-not($_.IsCoreGroup)} | %{$_.Name}

write-host ""
write-host ""

#START Comparing

#Buscamos recursos en el CSV para aplicar el TAG de antiafinidad
write-host ""

Foreach ($res in $Resgroups) 
	{

			    #Definimos el objeto $Tag y el valor que vamos a aplicar
			    $tag = New-Object System.Collections.Specialized.StringCollection
			    $tag.add("")
					
			    write-host ""
			    write-host "Limpiando el resgrpup $res el tag de antiafinidad...." -foregroundcolor Yellow
			    (Get-ClusterGroup  $res -cluster $args[0]).AntiAffinityClassNames=$tag

	}


write-host ""
write-host "Mostrando los valores de antiafinidad" -foregroundcolor Green
Get-ClusterGroup -cluster $args[0] | where-object {-not($_.IsCoreGroup)} | ft Name, AntiAffinityClassNames -AutoSize