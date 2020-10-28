<#
$GroupOnlineEvent = Get-Winevent -ListProvider Microsoft-Windows-FailoverClustering
$GroupOnlineEvent.Events | ? {$_.id -eq 1201}

The Cluster service successfully brought the clustered role '%1' online.
#>
#v1.0 Script
$Query = @"
<QueryList>
  <Query Id="0" Path="Microsoft-Windows-FailoverClustering/Operational">
    <Select Path="Microsoft-Windows-FailoverClustering/Operational">*[System[(Level=4 or Level=0) and (EventID=1201) and TimeCreated[timediff(@SystemTime) &lt;= 432000000]]]</Select>
  </Query>
</QueryList>
"@

#Get current date/time
$Date = Get-Date -f yyyy_MM_dd_hhmmss

#Get VM Name pattern
$VMName = Read-Host "Enter VM NAME"

$cluster = get-cluster -Domain $env:USERDOMAIN | Select-Object Name | Out-GridView -Title "Select your Cluster" -OutputMode Single 

$servers = Get-ClusterNode -Cluster $cluster.name | select -ExpandProperty Name

ForEach ($server in $servers) {
    $events = Get-WinEvent -FilterXml $Query -ComputerName $server

    ForEach ($Event in $Events) {
        # Convert the event to XML
        $eventXML = ([xml]$Event.ToXml()).Event.EventData.Data
        Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name  ResourceGroup -Value $eventXML.'#text'
        }
    write-host "Searching for events 1201 'The Cluster service successfully brought the clustered role ONLINE' with the pattern '$VMname' for server $server" -ForegroundColor Yellow
    $Events | Where-Object {$_.ResourceGroup -match "$VMName"} | ft TimeCreated, ResourceGroup -AutoSize
    #$Events | Where-Object {$_.ResourceGroup -match "$VMName"} | Export-Csv -Path .\$date-GroupOnline.csv -Append -NoTypeInformation
}
