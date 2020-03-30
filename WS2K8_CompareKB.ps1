$ComputerHotFIX = get-content ".\ComputerHF.txt"
#$ComputerHotFIX = Get-HotFix -ComputerName carlosm-lap | Select * | %{$_.HotfixID}
$ListHotFix = get-content ".\ListHF.txt"

if (Test-Path .\NotInComputer.txt) 
    {del "NotInComputer.txt"}
else{}

new-Item ".\NotInComputer.txt" -Type file

Foreach ($HotFix in $ListHotFix)
{
    If ($ComputerHotFIX -contains $Hotfix)
    {Write-Host $HotFix Found -ForegroundColor Green}
    else
    {Add-content ".\NotInComputer.txt" $HotFix}

}
Write-Host ""
Write-host "-> Review the OutPut File NotInComputer.txt" -ForegroundColor Green 