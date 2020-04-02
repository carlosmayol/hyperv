$memsize = 1GB 
$Array = New-Object Byte[] $memsize 
$random = [System.Security.Cryptography.RandomNumberGenerator]::Create() 
$random.GetBytes($Array) 
read-host 
