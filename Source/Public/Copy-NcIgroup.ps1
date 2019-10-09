function Copy-NcIgroup
{
    <#
    .SYNOPSIS
    This script will clone an igroup from 7g or cDOT and will facilitate the creation of an associated portset.
 
    .DESCRIPTION
    Use Get-NcIgroup or Get-NaIgroup to find the igroup that you would like to clone. This function will copy the contents of the object into a new igroup and will allow you to create a new portset for this igroup as well.

    .EXAMPLE
    Copy an igroup (vmware_rdm) from a 7-Mode controller (node01) onto a Clustered Data ONTAP cluster (cluster01). Create a new portset named newVM and add four ports to the portset (fc01,fc02,fc03,fc04). Finally show the progress with -verbose switch.
    PS > Get-NaIgroup vmware_rdm | Copy-NcIgroup -NewName newVM -NewPortSetName newVM -NewPortSetPorts fc01,fc02,fc03,fc04 -Vserver vmwareSvm -Verbose

        Name            : newVM
        Type            : vmware
        Protocol        : fcp
        Portset         : newVM
        ALUA            : True
        ThrottleBorrow  : False
        ThrottleReserve : 0
        Partner         : True
        VSA             : False
        Initiators      : {10:00:00:90:fa:1c:45:2f, 10:00:00:90:fa:1c:79:2d, 10:00:00:90:fa:1c:79:55,
                        10:00:00:90:fa:1c:79:63...}
        Vserver         : vmwareSvm 
    #>
    [CmdletBinding( DefaultParameterSetName = 'NcNoPortset')]
    [OutputType( [DataONTAP.C.Types.Igroup.InitiatorGroupInfo])]
    Param(
        #The object that comes from Get-NaIgroup
        [Parameter( ParameterSetName = 'NaOldPortset', Mandatory, ValueFromPipeline = $True )]
        [Parameter( ParameterSetName = 'NaNewPortset', Mandatory, ValueFromPipeline = $True )]
        [DataONTAP.Types.Lun.InitiatorGroupInfo]$NaIgroup
        ,
        #The object that comest from Get-NcIgroup
        [Parameter( ParameterSetName = 'NcOldPortset', Mandatory, ValueFromPipeline = $True )]
        [Parameter( ParameterSetName = 'NcNewPortset', Mandatory, ValueFromPipeline = $True )]
        [Parameter( ParameterSetName = 'NcNoPortset', Mandatory, ValueFromPipeline = $True )]
        [DataONTAP.C.Types.Igroup.InitiatorGroupInfo]$NcIgroup
        ,
        #The Name the igroup will be called on the cDOT system.
        [Parameter( ParameterSetName = 'NaNewPortset', Mandatory )]
        [Parameter( ParameterSetName = 'NcNewPortset', Mandatory )]
        [Parameter( ParameterSetName = 'NcNoPortset', Mandatory )]
        [String]$NewName
        ,
        #Map the Igroup to an existing PortSet
        [Parameter( ParameterSetName = 'NcOldPortset' )]
        [Parameter( ParameterSetName = 'NaOldPortset' )]
        [String]$PortSet
        ,
        #The name of a new portset
        [Parameter( ParameterSetName = 'NcNewPortset', Mandatory )]
        [Parameter( ParameterSetName = 'NaNewPortset', Mandatory )]
        [String]$NewPortSetName
        ,
        #The ports that you want to add to the new portset. e.g. fc01,fc02,fc03,fc04
        [Parameter( ParameterSetName = 'NcNewPortset', Mandatory )]
        [Parameter( ParameterSetName = 'NaNewPortset', Mandatory )]
        [String[]]$NewPortSetPorts
        ,
        #The Name of the vserver where this igroup will be created on.
        [Parameter( Mandatory )]
        [String]$Vserver,

        #The connection to the cluster
        [NetApp.Ontapi.Filer.C.NcController]$Controller
    )
    begin
    {
        if ( -not $PSBoundParameters.ContainsKey( 'Controller' ) )
        {
            Write-Verbose 'Controller parameter is not present using global variable'
            if ( -not $global:CurrentNcController )
            {
                throw "You must be connected to a NetApp cluster in order for this script to work."
            }
            
            [NetApp.Ontapi.Filer.C.NcController]$Controller = $global:CurrentNcController
        }
    }
    process
    {
        if ( $NaIgroup )
        {
            Write-Verbose "Using 7-Mode Igroup Properties"

            $Igroup = $NaIgroup
        }
        if ( $NcIgroup )
        {
            Write-Verbose "Using cDOT Igroup Properties"

            $Igroup = $NcIgroup
        }
        if ( $NewPortSetName )
        {
            try
            {
                Write-Verbose "Creating PortSet"

                New-NcPortset -Name $NewPortSetName -Protocol ( $Igroup.Protocol ) -VserverContext $Vserver -ErrorAction stop -Controller $Controller | Out-Null

                $PortSet = $NewPortSetName

                Write-Verbose " - Adding ports"

                foreach ( $port in $NewPortSetPorts )
                {
                    Write-Verbose " - > $port"

                    Add-NcPortsetPort -Name $NewPortSetName -Port $Port -VserverContext $Vserver -Controller $Controller | Out-Null
                }
            }
            catch
            {
                throw "There was an error during the creation of the Portset: $_"
            }
        }
        try
        {
            Write-Verbose "Creating Igroup"

            $newIgroupParam = @{
                Name           = $NewName
                Protocol       = ( $Igroup.Protocol ) 
                Type           = ( $Igroup.Type )
                VserverContext = $Vserver 
                ErrorAction    = 'Stop'
            }
            if ( $portset )
            {
                $newIgroupParam.Add( 'Portset', $PortSet )
            }
            New-NcIgroup @newIgroupParam -Controller $Controller | Out-Null

            Write-Verbose " - Adding Initiators"

            foreach ( $initiator in $Igroup.Initiators.InitiatorName )
            {
                Write-Verbose " - > $initiator"
                
                Add-NcIgroupInitiator -Name $NewName -Initiator $initiator -VserverContext $Vserver -Controller $Controller | Out-Null
            }
            Get-NcIgroup -Name $NewName -Controller $Controller 
        }
        catch
        {
            throw "There was an error during the creation of the igroup: $_"
        }
    }
}