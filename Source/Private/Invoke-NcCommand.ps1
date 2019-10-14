function Invoke-NcCommand
{
    <#
    .SYNOPSIS
        A command for handling the invocation of NetApp Commands with a retry in case the command fails due to a connection error.

    .DESCRIPTION
        A command for handling the invocation of NetApp Commands with a retry in case the command fails due to a connection error.

    .Example
        PS > Invoke-NcCommand -Script { Get-NcVol -Controller $connection }

        Name                      State       TotalSize  Used  Available Dedupe Aggregate                 Vserver
        ----                      -----       ---------  ----  --------- ------ ---------                 -------
        VolCreationTest           online        10.0 GB    0%    10.0 GB  True  aggr0                     CifsSvm01
    #>
    [CmdletBinding()]
    [OutputType( [object[]] )]
    param(
        [scriptblock] $Script,

        [int] $RetryCount = 3
    )

    Set-StrictMode -Version 2.0

    [int]$iteration = 0

    do
    {
        try
        {
            $returnObj = $Script.Invoke()

            return $returnObj
        }
        catch [NetApp.Ontapi.NaConnectionSSLException]
        {
            if ( $iteration -lt $RetryCount )
            {
                Write-Information -MessageData "The connection to the NetApp Cluster was lost"
            }
            else
            {
                throw "The connection to the NetApp Cluster was lost and all retries have been exhausted."
            }

            $iteration++
        }
        catch
        {
            $Global:Error.RemoveAt(0)

            $msg = [System.Text.StringBuilder]::new()

            if ( $PSItem.Exception.Message -match '\$global:CurrentNcController is not of type NetApp.Ontapi.Filer.C.NcController')
            {
                [void]$msg.AppendLine( 'No connection to the NetApp Cluster was provided.' )
                [void]$msg.AppendLine( '--------------------------------------------------------------------------------------------------' )
                [void]$msg.AppendLine( 'Attempt to re-run the automation. If this problem persists consider contacting support via e-mail' )
                [void]$msg.AppendLine( '--------------------------------------------------------------------------------------------------' )
                [void]$msg.AppendLine( $PSItem.Exception.Message )
                [void]$msg.AppendLine( "Location: $( $PSItem.ScriptStackTrace )" )
                [void]$msg.AppendLine()
            }
            else
            {
                [void]$msg.AppendLine( 'An unexpected error occurred. Processing halted.' )
                [void]$msg.AppendLine( '--------------------------------------------------------------------------------------------------' )
                [void]$msg.AppendLine( 'As this error is not expected, please consider contacting the support staff via e-mail or by' )
                [void]$msg.AppendLine( '--------------------------------------------------------------------------------------------------' )
                [void]$msg.AppendLine( $PSItem.Exception.Message )
                [void]$msg.AppendLine( "Location: $( $PSItem.ScriptStackTrace )" )
                [void]$msg.AppendLine()
            }
            $PSCmdlet.ThrowTerminatingError( [System.Management.Automation.ErrorRecord]::( $msg.ToString(), $PSItem.FullyQualifiedErrorId, $PSItem.CategoryInfo.Category, $PSItem.CategoryInfo.TargetName ) )
        }
    }
    while ( $iteration -lt $RetryCount )
}
