# Created version 0.1 by Carlos Mayol (carlosm)
# El equipo que ejecuta el script debe tener las RSAT para Failovecluster instaladas.


Set-StrictMode -version Latest

Clear-host

import-module failoverclusters

#Seccion de definición de variables

#Definimos el cluster a buscar
$cluster= "ipbhitvhostcv03"

#Definimos el parametro de busqueda de la VM
[string]$Chain= "SGDB11"

#Definimos el valor de la etiqueta a configurar con antiaffinidad
[string]$TagStr= ""



write-host ""
write-host "Buscando en el cluster "$cluster" ResGroups que hagan match con la variable "$Chain" " -foregroundcolor Yellow


#Vemos el TAG de antiafinidad para un Resource Group
write-host ""
write-host "Mostrando los valores de antiafinidad" -foregroundcolor magenta
Get-ClusterGroup -cluster $cluster | Where-Object {$_.Name -match "$Chain"} | fl Name, AntiAffinityClassNames

#Definimos el objeto $Tag y el valor que vamos a crear
$tag = New-Object System.Collections.Specialized.StringCollection
$tag.add("$TagStr")

write-host ""
write-host "Configurando los valores de antiafinidad: "$TagStr" ...." -foregroundcolor Green

#En caso de solo querer consultar, es suficiente con renombrar la linea inferior
Get-ClusterGroup -cluster $cluster | Where-Object {$_.Name -match "$Chain"} | %{$_.AntiAffinityClassNames = $tag}

write-host ""
write-host "Mostrando los valores de antiafinida nuevos" -foregroundcolor Green
Get-ClusterGroup -cluster $cluster | Where-Object {$_.Name -match "$Chain"} | fl Name, AntiAffinityClassNames