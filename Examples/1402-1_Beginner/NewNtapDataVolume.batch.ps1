param ($Name, $Aggregate, $Size, $Vserver)

ipmo DataONTAP

Connect-NcController sim96 (Get-Credential)

$params = @{
    Name           = $Name
    Aggregate      = $Aggregate
    JunctionPath   = "/$Name"
    Size           = $Size
    VserverContext = $Vserver
}

New-NcVol @params
