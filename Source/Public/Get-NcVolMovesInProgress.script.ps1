<#
    .SYNOPSIS
    Get status of move operation.
 
    .DESCRIPTION
    Get status of move operation.

    .EXAMPLE
    C:\PS>Get-NcVolMoveInProgress

        Get all of the volume move operations.
#>
[CmdletBinding( DefaultParameterSetName = "Set 1" )]
[OutputType([psobject], ParameterSetName = "Set 1" )]
Param(
    #The name of the vserver
    [Parameter( ParameterSetName = 'Set 1' )]
    [String]
    $Vserver
    ,
    #The name of the volume
    [Parameter( ParameterSetName = 'Set 1' )]
    [String]
    $Name
    ,
    #Show all volumes no matter if they are not in progress
    [Parameter( ParameterSetName = 'Set 1' )]
    [Switch]
    $All
) 
if ( -not $global:CurrentNcController )
{
    Throw 'You are not connected to a NetApp cluster, connect to the desired source cluster'
}       

$volMoveQueryObj = Get-NcVolMove -Template

if ( -not $PSBoundParameters.ContainsKey( 'All' ) )
{
    $volMoveQueryObj.State = "!failed"
    $volMoveQueryObj.PercentComplete = "!100"
}
if ( $Vserver )
{
    $volMoveQueryObj.Vserver = $Vserver
}
if ( $Name )
{
    $volMoveQueryObj.Volume = $Name
}
        
$volMoves = Get-NcVolMove -Query $volMoveQueryObj | Select-Object *

if ( $volMoves )
{
    foreach ( $vol in $volMoves )
    {
        $vol.pstypenames.Insert( 0, 'NetApp.NcVolMove' )
        $vol
    }
}        