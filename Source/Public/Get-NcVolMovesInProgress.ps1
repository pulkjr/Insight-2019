function Get-NcVolMovesInProgress
{
    <#
    .SYNOPSIS
    Get status of move operation.
 
    .DESCRIPTION
    Get status of move operation.

    .EXAMPLE
    C:\PS>Get-NcVolMoveInProgress

        Get all of the volume move operations.

        ActualCompletionTimestamp            :
        ActualDuration                       : 4
        BytesRemaining                       :
        BytesSent                            :
        CompletionCode                       :
        CompletionStatus                     :
        CutoverAction                        : defer_on_failure
        CutoverAttemptedCount                : 0
        CutoverAttempts                      : 3
        CutoverHardDeferredCount             : 0
        CutoversSoftDeferredCount            : 0
        CutoverTriggerTimestamp              :
        CutoverWindow                        : 45
        DestinationAggregate                 : aggr2
        DestinationNode                      : tesla-01
        Details                              : Volume move job in setup
        EstimatedCompletionTime              :
        EstimatedRemainingDuration           :
        ExecutionProgress                    : Volume move job in setup
        InternalState                        : Setup
        JobId                                : 29
        JobUuid                              : 0ccc0fb4-ca96-11e1-a2e1-123478563412
        LastCutoverTriggerTimestamp          :
        ManagingNode                         : tesla-01
        NcController                         : 192.168.182.119
        PercentComplete                      :
        Phase                                : initializing
        PriorIssues                          :
        ReplicationThroughput                :
        SourceAggregate                      : aggr1
        SourceNode                           : tesla-01
        StartTimestamp                       : 1341928161
        State                                : healthy
        Volume                               : vol1
        Vserver                              : joule
 
    #>
    [CmdletBinding( DefaultParameterSetName = "Set 1" )]
    [OutputType( [psobject], ParameterSetName = "Set 1" )]
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

    begin
    {
        if ( -not $global:CurrentNcController )
        {
            Throw 'You are not connected to a NetApp cluster, connect to the desired source cluster'
        }       
    }
    process
    {
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
    }
}