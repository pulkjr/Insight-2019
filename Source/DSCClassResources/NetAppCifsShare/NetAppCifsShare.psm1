[DscResource()]
class NetAppCifsShare
{
    #The name is not modifiable
    [DscProperty( Key, Mandatory )]
    [string] $Name

    [DscProperty( Mandatory )]
    [string] $Path

    [DscProperty( Mandatory )]
    [string] $Vserver

    [DscProperty( Mandatory )]
    [String] $Controller

    [DscProperty( Mandatory )]
    [PSCredential] $Credential

    [DscProperty( Mandatory )]
    [ValidateSet( 'Absent', 'Present' )]
    [String] $Ensure = 'Present'

    [DscProperty()]
    [ValidateSet( 'oplocks', 'browsable', 'showsnapshot', 'changenotify', 'homedirectory', 'attributecache', 'show_previous_versions' )]
    [String[]] $ShareProperties

    [DscProperty()]
    [ValidateSet( 'enable', 'hide', 'read_only', 'symlinks' )]
    [String[]] $SymlinkProperties

    [DscProperty()]
    [String] $Comment

    [DscProperty()]
    [ValidateSet( 'none', 'manual', 'documents', 'programs' )]
    [String] $OfflineFilesMode

    [DscProperty()]
    [ValidateSet( 'no_scan', 'standard', 'strict', 'writes_only' )]
    [String] $VscanProfile

    [DscProperty()]
    [Int64] $MaxConnectionsPerShare

    [DscProperty()]
    [Bool] $HTTPS = $true

    [DscProperty()]
    [Int32] $Timeout = 300000

    hidden [NetApp.Ontapi.Filer.C.NcController] $NcController

    hidden [DataONTAP.C.Types.Cifs.CifsShare] $CurrentSettings

    hidden [void] NewVerboseMessage( [string]$message )
    {
        Write-Information -Message ( "{0}:{1}" -f ( Get-Date -format yyyy-MM-dd_HH-mm-ss ), $message )
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
    [void]RemoveNetAppCifsShare()
    {
        if ( $this.Ensure -ne 'Absent' )
        {
            return
        }
        if ( -not $this.CurrentSettings )
        {
            $this.NewVerboseMessage( 'The resource was not found. Nothing to remove.' )
            return
        }
        [hashtable]$_removeShareParam = @{
            Name           = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }

        Remove-NcCifsShare @_removeShareParam -Confirm:$false
        return
    }
    [void]NewNetAppCifsShare()
    {
        if ( $this.CurrentSettings )
        {
            return
        }
        [hashtable]$_shareParam = @{
            Name           = $this.Name
            Path           = $this.Path
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }
        if ( @( $this.ShareProperties ).count -gt 0 )
        {
            $_shareParam.Add( 'ShareProperties', $this.ShareProperties )
        }
        if ( [string]::IsNullOrEmpty( $this.OfflineFilesMode ) -eq $false )
        {
            $_shareParam.Add( 'OfflineFilesMode', $this.OfflineFilesMode )
        }
        if ( [string]::IsNullOrEmpty( $this.VscanProfile ) -eq $false )
        {
            $_shareParam.Add( 'VscanProfile', $this.VscanProfile )
        }
        if ( $this.MaxConnectionsPerShare -gt 0 )
        {
            $_shareParam.Add( 'MaxConnectionsPerShare', $this.MaxConnectionsPerShare )
        }

        $this.CurrentSettings = Add-NcCifsShare @_shareParam
        return
    }
    [void]SetNetAppCifsShare()
    {
        if ( -not $this.CurrentSettings )
        {
            $this.NewVerboseMessage( 'The resource was not found. Run the set method again.' )
            return
        }
        [hashtable]$_setShareParam = @{
            Name           = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }
        if ( $this.CurrentSettings.Path -ne $this.Path )
        {
            $_setShareParam.Add( 'Path', $this.Path )
        }
        if ( $this.CurrentSettings.Comment -ne $this.Comment )
        {
            $_setShareParam.Add( 'Comment', $this.Comment )
        }
        if ( $this.CurrentSettings.OfflineFilesMode -ne $this.OfflineFilesMode )
        {
            $_setShareParam.Add( 'OfflineFilesMode', $this.OfflineFilesMode )
        }
        if ( $this.CurrentSettings.VscanFileopProfile -ne $this.VscanProfile )
        {
            $_setShareParam.Add( 'VscanProfile', $this.VscanProfile )
        }
        if ( $this.CurrentSettings.MaxConnectionsPerShare -ne $this.MaxConnectionsPerShare -and $this.MaxConnectionsPerShare -gt 0 )
        {
            $_setShareParam.Add( 'MaxConnectionsPerShare', $this.MaxConnectionsPerShare )
        }
        foreach ( $_shareProperty in $this.ShareProperties )
        {
            if ( $_shareProperty -notin $this.CurrentSettings.ShareProperties )
            {
                $_setShareParam.Add( 'ShareProperties', $this.ShareProperties )
                break
            }
        }
        foreach ( $_symlinkProperty in $this.SymlinkProperties )
        {
            if ( $_symlinkProperty -notin $this.CurrentSettings.SymlinkProperties )
            {
                $_setShareParam.Add( 'SymlinkProperties', $this.SymlinkProperties )
                break
            }
        }

        Set-NcCifsShare @_setShareParam
        return
    }
    [void]GetCurrentSettings()
    {
        $this.ConnectONTAP()

        $_getParams = @{
            Name           = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }

        $this.CurrentSettings = Get-NcCifsShare @_getParams
    }
    [NetAppCifsShare] Get()
    {
        $this.NewVerboseMessage( 'Start Get Method' )

        $this.GetCurrentSettings()

        if ( -not $this.CurrentSettings )
        {
            return [NetAppCifsShare]::new()
        }
        $_returnShare = [NetAppCifsShare]::new()
        $_returnShare.Name = $this.CurrentSettings.ShareName
        $_returnShare.Path = $this.CurrentSettings.Path
        $_returnShare.Controller = $this.Controller
        $_returnShare.Credential = $this.Credential
        $_returnShare.Ensure = $this.Ensure
        $_returnShare.Vserver = $this.CurrentSettings.Vserver
        $_returnShare.ShareProperties = $this.CurrentSettings.ShareProperties
        $_returnShare.SymlinkProperties = $this.CurrentSettings.SymlinkProperties

        if ( [string]::IsNullOrEmpty( $this.CurrentSettings.Comment ) -eq $false )
        {
            $_returnShare.Comment = $this.CurrentSettings.Comment
        }
        if ( [string]::IsNullOrEmpty( $this.CurrentSettings.OfflineFilesMode ) -eq $false )
        {
            $_returnShare.OfflineFilesMode = $this.CurrentSettings.OfflineFilesMode
        }
        if ( [string]::IsNullOrEmpty( $this.CurrentSettings.VscanFileopProfile ) -eq $false )
        {
            $_returnShare.VscanProfile = $this.CurrentSettings.VscanFileopProfile
        }
        if ( $this.CurrentSettings.MaxConnectionsPerShareSpecified -eq $true )
        {
            $_returnShare.MaxConnectionsPerShare = $this.CurrentSettings.MaxConnectionsPerShare
        }

        return $_returnShare
    }
    [void] Set()
    {
        $this.NewVerboseMessage( 'Start Set Method' )

        $this.GetCurrentSettings()

        if ( $this.Ensure -eq 'Absent' )
        {
            $this.RemoveNetAppCifsShare()
            return
        }
        $this.NewNetAppCifsShare()

        $this.SetNetAppCifsShare()
    }
    [bool] Test()
    {
        $this.GetCurrentSettings()

        if ( -not $this.CurrentSettings -and $this.Ensure -eq 'Absent' )
        {
            $this.NewVerboseMessage( 'The Share was not found and Ensure = Absent, this is the correct config' )
            return $true
        }
        if ( $this.CurrentSettings -and $this.Ensure -eq 'Absent' )
        {
            $this.NewVerboseMessage( 'The Share was found and Ensure = Absent' )
            return $false
        }
        if ( $this.CurrentSettings.Path -ne $this.Path )
        {
            $this.NewVerboseMessage( [string]::Format( 'The Path is supposed to be: {0} but is: {1}', $this.Path, $this.CurrentSettings.Path ) )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.Comment ) -eq $false -and $this.CurrentSettings.Comment -ne $this.Comment )
        {
            $this.NewVerboseMessage( [string]::Format( 'Comment is supposed to be: {0} but is: {1}', $this.Comment, $this.CurrentSettings.Comment ) )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.OfflineFilesMode ) -eq $false -and $this.CurrentSettings.OfflineFilesMode -ne $this.OfflineFilesMode )
        {
            $this.NewVerboseMessage( [string]::Format( 'OfflineFilesMode is supposed to be: {0} but is: {1}', $this.OfflineFilesMode, $this.CurrentSettings.OfflineFilesMode ) )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.VscanProfile ) -eq $false -and $this.CurrentSettings.VscanFileopProfile -ne $this.VscanProfile )
        {
            $this.NewVerboseMessage( [string]::Format( 'VscanProfile is supposed to be: {0} but is: {1}', $this.VscanProfile, $this.CurrentSettings.VscanFileopProfile ) )
            return $false
        }
        if ( $this.CurrentSettings.MaxConnectionsPerShare -ne $this.MaxConnectionsPerShare -and $this.MaxConnectionsPerShare -gt 0 )
        {
            $this.NewVerboseMessage( [string]::Format( 'MaxConnectionsPerShare is supposed to be: {0} but is: {1}', $this.MaxConnectionsPerShare, $this.CurrentSettings.MaxConnectionsPerShare ) )
            return $false
        }
        foreach ( $_shareProperty in $this.ShareProperties )
        {
            if ( [string]::IsNullOrEmpty( $_shareProperty ) -eq $false -and $_shareProperty -notin $this.CurrentSettings.ShareProperties )
            {
                $this.NewVerboseMessage( [string]::Format( 'ShareProperties should contain: {0}', $_shareProperty ) )
                return $false
                break
            }
        }
        foreach ( $_symlinkProperty in $this.SymlinkProperties )
        {
            if ( [string]::IsNullOrEmpty( $_symlinkProperty ) -eq $false -and $_symlinkProperty -notin $this.CurrentSettings.SymlinkProperties )
            {
                $this.NewVerboseMessage( [string]::Format( 'SymlinkProperties should contain: {0}', $_symlinkProperty ) )
                return $false
                break
            }
        }
        return $true
    }
}
