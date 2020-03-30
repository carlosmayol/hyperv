# Created version 0.1 by Carlos Mayol
# El equipo que ejecuta el script debe tener las RSAT para Failovecluster instaladas.
# El fichero CSV debe contener dos columnas Resource y Tag que contenga el nombre de los resGroup y las etiquetas a aplicar.

# "Use: .\SetAffinityv2.ps1 CLUSTERNAME CSVFILE"

Set-StrictMode -version Latest

Clear-host

import-module failoverclusters

#STARTING SCRIPT

#Almacenamos los resGroups del cluster que no sean CoreResources
$Resgroups = Get-ClusterGroup -cluster $args[0] | where-object {-not($_.IsCoreGroup)} | %{$_.Name}

#Importamos el valor del fichero con la lista de afinidades
$tagstr= import-csv $args[1]

write-host ""
write-host ""

#START Comparing

#Buscamos recursos en el CSV para aplicar el TAG de antiafinidad
write-host ""

Foreach ($res in $Resgroups) 
	{
	[int]$row=0
	do 
		{ 
            if ($res -eq $tagstr[$row].resource)
			    {
			    #Definimos el objeto $Tag y el valor que vamos a aplicar
			    $tag = New-Object System.Collections.Specialized.StringCollection
			    $tag.add($TagStr[$row].tag)
					
			    write-host ""
			    write-host "Configurando en $res el tag de antiafinidad: $tag ...." -foregroundcolor Green
			    (Get-ClusterGroup  $res -cluster $args[0]).AntiAffinityClassNames=$tag
			    }
            else { write-host "No se ha encontrado ningunca coincidencia para el recurso: $res"}
            [int]$row=$row+1
	    }		
 
	until ($row -eq $tagstr.count)
	}


write-host ""
write-host "Mostrando los valores de antiafinidad" -foregroundcolor Green
Get-ClusterGroup -cluster $args[0] | where-object {-not($_.IsCoreGroup)} | ft Name, AntiAffinityClassNames -AutoSize