function Get-NcAggrSpaceInfo
{
    <#
    .SYNOPSIS
    Get aggregate space information
 
    .DESCRIPTION
    Get aggregate space information

    .EXAMPLE
    C:\PS>Get-NcAggrSpaceInfo
 
    #>
    [CmdletBinding( )]
    [OutputType( [psobject])]
    Param(
        #The name of the Aggregate
        [Parameter( )]
        [String]
        $Name
    ) 
    if ( -not $global:CurrentNcController )
    {
        Throw 'You are not connected to a NetApp cluster, connect to the desired source cluster'
    }       
    $aggrs = Get-NcAggrSpace -Name $Name | Select-Object *

    if ( $aggrs )
    {
        foreach ( $aggr in $aggrs )
        {
            $aggr.pstypenames.Insert( 0, 'NetApp.NcAggr.Space' )
            $aggr
        }
    }        
}