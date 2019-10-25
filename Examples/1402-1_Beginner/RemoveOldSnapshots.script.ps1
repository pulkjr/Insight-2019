# This assumes the DataONTAP module is already imported and the $global:CurrentNcController variable is populated
# with at least 1 connection object.
param (
    [string[]]$Vserver,

    [string[]]$Volume,

    [int]$DaysToKeep = 30
)

$params = @{ }

if ($Vserver)
{
    $params.Add('Vserver', $Vserver)
}

if ($Volume)
{
    $params.Add('Volume', $Volume)
}

Get-NcSnapshot @params | Where-Object { $_.Created -lt [datetime]::Now.AddDays("-$DaysToKeep") } | Remove-NcSnapshot -WhatIf
