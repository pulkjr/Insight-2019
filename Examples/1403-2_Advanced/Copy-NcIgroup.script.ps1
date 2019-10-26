<#
    .SYNOPSIS
    This script will clone an igroup from 7g or cDOT and will facilitate the creation of an associated portset.

    .DESCRIPTION
    Use Get-NcIgroup or Get-NaIgroup to find the igroup that you would like to clone. This function will copy the contents of the object into a new igroup and will allow you to create a new portset for this igroup as well.

    .EXAMPLE
    Copy an igroup (vmware_rdm) from a 7-Mode controller (node01) onto a Clustered Data ONTAP cluster (cluster01). Create a new portset named newVM and add four ports to the portset (fc01,fc02,fc03,fc04). Finally show the progress with -verbose switch.
    PS > Get-NaIgroup vmware_rdm | Copy-NGEN-NcIgroup -NewName newVM -NewPortSetName newVM -NewPortSetPorts fc01,fc02,fc03,fc04 -Vserver vmwareSvm -Verbose

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
    .NOTES
    TODO : Add support for pipeline
    TODO : Add 7-Mode systems support
    TODO : Add ability to collect from one cluster and create on another cluster
#>
Param(
    #The name of the Igroup
    [String]
    $IgroupName
    ,
    #The Name the igroup will be called on the cDOT system.
    [String]
    $NewName
    ,
    #Map the Igroup to an existing PortSet
    [String]
    $PortSet
    ,
    #The name of a new portset
    [String]
    $NewPortSetName
    ,
    #The ports that you want to add to the new portset. e.g. fc01,fc02,fc03,fc04
    [String[]]
    $NewPortSetPorts
    ,
    #The Name of the vserver where this igroup will be created on.
    [String]
    $Vserver
)
if ( -not $global:CurrentNcController )
{
    throw "You must be connected to a NetApp cluster in order for this script to work. Use Connect-NcController -Name <ClusterName>"
}

$Igroup = Get-NcIgroup -Name $IgroupName #? Should this command be in here? Shouldn't the user do this from the pipeline?

if ( -Not $Igroup )
{
    throw "The Igroup $IgroupName could not be found."
}
if ( $NewPortSetName )
{
    try
    {
        Write-Verbose "Creating PortSet"

        New-NcPortset -Name $NewPortSetName -Protocol ( $Igroup.Protocol ) -VserverContext $Vserver -ErrorAction stop | Out-Null

        $PortSet = $NewPortSetName

        Write-Verbose " - Adding ports"

        foreach ( $port in $NewPortSetPorts )
        {
            Write-Verbose " - > $port"

            Add-NcPortsetPort -Name $NewPortSetName -Port $Port -VserverContext $Vserver | Out-Null
        }
    }
    catch
    {
        Write-Error "There was an error during the creation of the Portset" -ErrorAction stop
    }
}
try
{
    Write-Verbose "Creating Igroup"

    New-NcIgroup -Name $NewName -Protocol ( $Igroup.Protocol ) -Type ( $Igroup.Type ) -Portset $PortSet -VserverContext $Vserver -ErrorAction Stop | Out-Null

    Write-Verbose " - Adding Initiators"

    foreach ( $initiator in $Igroup.Initiators.InitiatorName )
    {
        Write-Verbose " - > $initiator"

        Add-NcIgroupInitiator -Name $NewName -Initiator $initiator -VserverContext $Vserver | Out-Null
    }
    Get-NcIgroup -Name $NewName
}
catch
{
    Write-Error "There was an error during the creation of the igroup: $_" -ErrorAction stop
}