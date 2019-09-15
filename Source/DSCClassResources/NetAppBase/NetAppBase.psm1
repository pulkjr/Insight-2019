[DscResource()]
class NetAppBase
{
    [DscProperty( Key, Mandatory )]
    [String] $Controller

    [DscProperty( Mandatory )]
    [PSCredential] $Credential

    [DscProperty( Mandatory )]
    [ValidateSet( 'Absent', 'Present' )]
    [String] $Ensure

    [DscProperty()]
    [Bool] $HTTPS = $true

    [DscProperty()]
    [Int32] $Timeout = 300000

    hidden [version] $NcVersion

    hidden [NetApp.Ontapi.Filer.C.NcController] $NcController

    hidden [void] NewVerboseMessage( [string]$message )
    {
        Write-Information -MessageData $( "{0}:{1}" -f ( Get-Date -format yyyy-MM-dd_HH-mm-ss ), $message )
    }
    hidden [void] ConnectONTAP()
    {
        try
        {
            # speeds up the connection to ontap by skipping the cmdlet reporting step.
            $DataOntap_SkipEMSReport = $true

            if ( -not [string]::IsNullOrEmpty( $this.NcController ) )
            {
                if ( ( -not [string]::IsNullOrEmpty( $this.NcController.Version ) ) -AND
                    ( -not [string]::IsNullOrEmpty( $this.NcController.Name ) ) )
                {
                    $this.NewVerboseMessage( ( "Using Cached Connection to {0}..." -f $this.NcController.Name ) )
                    return
                }
            }
            $this.NewVerboseMessage( ( "Connecting to {0}..." -f $this.Controller ) )
            if ( -not [string]::IsNullOrEmpty( $this.Credential.UserName ) )
            {

                $connectSplat = @{
                    Name        = $this.Controller
                    Credential  = $this.Credential
                    Transient   = $true
                    ErrorAction = 'Stop'
                    Timeout     = $this.Timeout
                }

                if ( $this.HTTPS -eq $true )
                {
                    $this.NewVerboseMessage( "- Using a HTTPS connection" )
                    $connectSplat.Add( 'HTTPS', $true )
                }

                $this.NewVerboseMessage( ( "- Executing Connect-NcController to {0}" -f $this.Controller ) )
                [NetApp.Ontapi.Filer.C.NcController] $_clusterConnection = Connect-NcController @connectSplat -verbose:$false

                if ( ( -not [string]::IsNullOrEmpty( ( $_clusterConnection.Version ) ) ) -and ( -not [string]::IsNullOrEmpty( ( $_clusterConnection.Name ) ) ) )
                {
                    $this.NcController = $_clusterConnection
                    $this.NcVersion = [version]::Parse( "$( $this.NcController.OntapiMajorVersion ).$( $this.NcController.OntapiMinorVersion )" )
                    $this.NewVerboseMessage( ( "- Connected to {0} running {1}" -f $_clusterConnection.Name, $_clusterConnection.Version ) )
                }
                else
                {
                    throw ( "Unable to connect to Cluster '{0}' using credentials '{1}'" -f $this.Controller, $this.Credential.UserName )
                    break
                }
            }
            else
            {
                throw ( "Invalid credential object provided. Ensure correct PSCredential object type." )
                break
            }
        }
        catch
        {
            $this.NewVerboseMessage( $_.exception.message )
            throw ( "Unable to connect to Cluster '{0}' using credentials '{1}' exception:{2}" -f $this.Controller, $this.Credential.UserName, $_.exception.message );
        }
    }
    [Decimal] ConvertSizeToBytesDecimal( [decimal]$Size, [String]$Size_Unit )
    {
        [Decimal]$_returnSize = 0

        switch ( $Size_Unit )
        {
            'kb'
            {
                [Decimal]$_returnSize = $Size * 1kb
            }
            'mb'
            {
                [Decimal]$_returnSize = $Size * 1mb
            }
            'gb'
            {
                [Decimal]$_returnSize = $Size * 1gb
            }
            'tb'
            {
                [Decimal]$_returnSize = $Size * 1tb
            }
            DEFAULT
            {
                [Decimal]$_returnSize = $Size
            }
        }

        return $_returnSize
    }
    hidden [bool] CompareSizes ( [string]$FirstSize, [string]$SecondSize )
    {
        [regex]$_sizeReg = '(?i)(?<Size>[0-9]+)(?<Size_Unit>mb|kb|gb|tb|pb){0,1}'

        $_firstMatchGroups = $_sizeReg.Match( $FirstSize ).Groups

        [decimal]$_firstSize = $_firstMatchGroups['Size'].Value

        if ( [string]::IsNullOrEmpty( $_firstMatchGroups['Size_Unit'].Value ) )
        {
            [string]$_firstSizeUnit = 'bytes'

            [decimal]$_firstByteValue = $_firstSize
        }
        else
        {
            [string]$_firstSizeUnit = $_firstMatchGroups['Size_Unit'].Value

            [decimal]$_firstByteValue = $this.ConvertSizeToBytesDecimal( $_firstSize, $_firstSizeUnit )
        }
        $_secondMatchGroups = $_sizeReg.Match( $SecondSize ).Groups

        [decimal]$_secondSize = $_secondMatchGroups['Size'].Value

        if ( [string]::IsNullOrEmpty( $_secondMatchGroups['Size_Unit'].Value ) )
        {
            [string]$_secondSizeUnit = 'bytes'

            [decimal]$_secondByteValue = $_secondSize
        }
        else
        {
            [string]$_secondSizeUnit = $_secondMatchGroups['Size_Unit'].Value

            [decimal]$_secondByteValue = $this.ConvertSizeToBytesDecimal( $_secondSize, $_secondSizeUnit )
        }
        if ( $_firstByteValue -eq $_secondByteValue )
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    [void] WaitNcJob ( [DataONTAP.C.Types.Job.JobInfo]$Job, [Int32]$WaitTimeMs )
    {
        $i = 0
        [DataONTAP.C.Types.Job.JobInfo]$_jobResults = $Job
        do
        {
            Start-Sleep -Milliseconds $WaitTimeMs

            [hashtable] $_jobQuery = @{
                JobUuid = $Job.JobUuid
            }
            if ( $Job.JobVserver )
            {
                $_jobQuery.add( 'JobVserver', $this.Vserver )
            }
            [DataONTAP.C.Types.Job.JobInfo]$_jobResults = Get-NcJob -Controller $this.NcController -Query $_jobQuery

            if ( -not $_jobResults )
            {
                $this.NewVerboseMessage( 'The job $( $Job.JobUuid ) was not found' )
                return
            }
            $i++
        }
        until ( $_jobResults.JobState -ne 'running' -or $i -gt 10 )

        if ( $_jobResults.JobState -eq 'running' )
        {
            $this.NewVerboseMessage( "The Job has not completed but the max retry count was hit, use Get-NcJob -JobUuid $( $Job.JobUuid ) for more information." )
        }
    }
    [NetAppBase] Get()
    {
        return $this
    }
    [void] Set()
    {
        return
    }

    [bool] Test()
    {
        return $true
    }
}
