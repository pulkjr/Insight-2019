function Get-NcLunCanonicalName
{
    <#
    .SYNOPSIS
    Used to get the Serial Number and VMware Conical Name of the LUN.
 
    .DESCRIPTION
    This command converts the ascii serial number that is derived from NetApp to the hex numbers provided by VMware.

    .EXAMPLE
    PS > Get-NcLunCanonicalName -Vserver CifSVM -Path /vol/server01.lun

    This will query the vserver for any LUNS that start with server01 and will provide the serial number and VMWare Conical Name (naa#).

    #>
    [CmdletBinding( DefaultParameterSetName = "Set 1", ConfirmImpact = "Low" )]
    [OutputType( [psobject], ParameterSetName = "Set 1" )]
    param(
        #The Name of the vserver
        [Parameter( ParameterSetName = 'Set 1' )]
        [String]
        $Vserver
        ,
        #The path to the lun. e.g. /vol/server01.lun
        [Parameter( ParameterSetName = 'Set 1' )]
        [String]
        $Path
        ,
        #Use the Get-NcLun command to pipe into this function. 
        [Parameter( ParameterSetName = 'Lun',
            Mandatory,
            ValueFromPipeline = $True, 
            Position = 0, 
            ValueFromPipelineByPropertyName = $True )]
        [DataONTAP.C.Types.Lun.LunInfo]
        $Lun
        ,
        #Use this to find a specific Lun by its ConicalName.
        [String]
        $ConicalName
    )
    begin
    {
        if ( -not $global:CurrentNcController )
        {
            Throw 'You are not connected to a cluster, connect to the desired cluster with Connect-NcController'
        }
    }
    process
    {
        $identifier = "naa.600a0980"

        if ( -not $Lun )
        {
            $lunAttrObj = Get-NcLun -Template
            $lunAttrObj.Vserver = $True
            $lunAttrObj.Path = $True
            $lunAttrObj.Volume = $true

            $lunArr = Get-NcLun -Vserver $Vserver -Path $Path -Attributes $lunAttrObj
        }
        else
        {
            $lunArr = $Lun
        }
        foreach ( $lunObj in $lunArr )
        {
            $returnObj = $lunObj | Get-NcLunSerialNumber | Select-Object Path, Vserver, SerialNumber, NcController
            $returnObj | Add-Member -MemberType NoteProperty -Name "CanonicalName" -Value "$identifier$( [InsightBase]::GetPSAsciiToHex( $lunObj.SerialNumber ) )"
            $returnObj | Add-Member -MemberType NoteProperty -Name "Volume" -Value $lunObj.Volume

            if ( -not $PSBoundParameters.ContainsKey( 'ConicalName' ) -or $returnObj.CanonicalName -eq $ConicalName )
            {
                $returnObj
            }
        }
    }
}
