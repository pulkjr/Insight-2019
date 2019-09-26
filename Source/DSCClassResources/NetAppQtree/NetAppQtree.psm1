[DscResource()]
class NetAppQtree : NetAppBase
{
    [DscProperty( Key, Mandatory )]
    [string] $Name

    [DscProperty( Key, Mandatory )]
    [string] $Volume

    [DscProperty( Key, Mandatory )]
    [string] $Vserver

    [DscProperty()]
    [String] $Mode

    #Indicates whether opportunistic locks are enabled on the qtree.
    [DscProperty()]
    [ValidateSet( "enabled", "disabled" )]
    [String] $Oplocks

    [DscProperty()]
    [ValidateSet( "unix", "ntfs", "mixed" )]
    [String] $SecurityStyle

    [DscProperty()]
    [String] $ExportPolicy

    [DscProperty( NotConfigurable )]
    [ValidateSet( "normal", "readonly" )]
    [String] $Status

    #Id of the qtree (unique within the volume), which is 0 if qtree is the volume itself.
    [DscProperty( NotConfigurable )]
    [Int32] $Id

    hidden [DataONTAP.C.Types.Qtree.QtreeInfo] $CurrentSettings

    [void]RemoveNetAppQtree()
    {
        $this.NewVerboseMessage( 'Entered RemoveNetAppQtree Method' )

        if ( -not $this.CurrentSettings )
        {
            $this.NewVerboseMessage( ' - Qtree does not exists and does not need to be removed.' )
            return
        }

        $this.NewVerboseMessage( ' - Qtree exists and must be absent, removing now.' )

        $_removeParams = @{
            Volume         = $this.Volume
            Qtree          = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
            Force          = $true
        }

        Remove-NcQtree @_removeParams -Confirm:$false
        return
    }
    [void]NewNetAppQtree()
    {
        if ( $this.CurrentSettings )
        {
            $this.NewVerboseMessage( ' - Qtree already exists and does not need to be created.' )
            return
        }
        $_newParams = @{
            Volume         = $this.Volume
            Qtree          = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }
        if ( $this.Mode )
        {
            $_newParams.Add( 'Mode', $this.Mode )
        }
        if ( $this.Oplocks )
        {
            $_newParams.Add( 'Oplocks', $this.Oplocks )
        }
        if ( $this.SecurityStyle )
        {
            $_newParams.Add( 'SecurityStyle', $this.SecurityStyle )
        }
        if ( $this.ExportPolicy )
        {
            $_newParams.Add( 'ExportPolicy', $this.ExportPolicy )
        }
        $this.NewVerboseMessage( ' - No Qtree found on SVM. Creating a new qtree now.' )

        New-NcQtree @_newParams -Confirm:$false

        $this.GetCurrentSettings()
        return
    }
    [void]SetNetAppQtree()
    {
        $this.NewVerboseMessage( 'Entered SetNetAppQtree Method' )
        $_setParams = @{
            Volume         = $this.Volume
            Qtree          = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }
        if ( $this.Mode )
        {
            if ( $this.Mode -ne $this.CurrentSettings.Mode )
            {
                $this.NewVerboseMessage( '- The qtree mode is set incorrectly, updating now' )

                Set-NcQtree @_setParams -Mode $this.Mode -Confirm:$false
            }
        }
        if ( $this.SecurityStyle )
        {
            if ( $this.SecurityStyle -ne $this.CurrentSettings.SecurityStyle )
            {
                $this.NewVerboseMessage( '- The qtree SecurityStyle is set incorrectly, updating now' )

                Set-NcQtree @_setParams -SecurityStyle $this.SecurityStyle -Confirm:$false
            }
        }
        if ( $this.ExportPolicy )
        {
            if ( $this.ExportPolicy -ne $this.CurrentSettings.ExportPolicy )
            {
                $this.NewVerboseMessage( '- The qtree ExportPolicy is set incorrectly, updating now' )

                Set-NcQtree @_setParams -ExportPolicy $this.ExportPolicy -Confirm:$false
            }
        }
        if ( $this.Oplocks )
        {
            if ( $this.Oplocks -ne $this.CurrentSettings.Oplocks )
            {
                $this.NewVerboseMessage( '- The qtree Oplocks is set incorrectly, updating now' )

                if ( $this.Oplocks -eq 'enabled' )
                {
                    Set-NcQtree @_setParams -EnableOplocks -Confirm:$false
                }
                if ( $this.Oplocks -eq 'disabled' )
                {
                    Set-NcQtree @_setParams -DisableOplocks -Confirm:$false
                }
            }
        }

        return
    }
    [void]GetCurrentSettings()
    {
        $this.ConnectONTAP()

        $_qtreeParameters = @{
            Volume         = $this.Volume
            Qtree          = $this.Name
            VserverContext = $this.Vserver
            Controller     = $this.NcController
        }
        $this.CurrentSettings = Get-NcQtree @_qtreeParameters
    }
    [NetAppQtree] Get()
    {
        $this.NewVerboseMessage( 'Start Get Method' )

        $this.GetCurrentSettings()

        if ( -not $this.CurrentSettings )
        {
            return [NetAppQtree]::new()
        }
        $_returnShare = [NetAppQtree]::new()
        $_returnShare.Controller = $this.Controller
        $_returnShare.Credential = $this.Credential
        $_returnShare.Ensure = $this.Ensure
        $_returnShare.Vserver = $this.CurrentSettings.Vserver
        $_returnShare.Name = $this.CurrentSettings.Qtree
        $_returnShare.ExportPolicy = $this.CurrentSettings.ExportPolicy
        $_returnShare.Id = $this.CurrentSettings.Id
        $_returnShare.Mode = $this.CurrentSettings.Mode
        $_returnShare.Oplocks = $this.CurrentSettings.Oplocks
        $_returnShare.SecurityStyle = $this.CurrentSettings.SecurityStyle
        $_returnShare.Status = $this.CurrentSettings.Status
        $_returnShare.Volume = $this.CurrentSettings.Volume

        return $_returnShare
    }
    [void] Set()
    {
        $this.NewVerboseMessage( 'Start Set Method' )

        $this.GetCurrentSettings()

        if ( $this.Ensure -eq 'Absent' )
        {
            $this.RemoveNetAppQtree()
            return
        }
        $this.NewNetAppQtree()

        $this.SetNetAppQtree()
    }
    [bool] Test()
    {
        $this.GetCurrentSettings()

        if ( -not $this.CurrentSettings -and $this.Ensure -eq 'Absent' )
        {
            $this.NewVerboseMessage( "The NetAppQtree was not found and Ensure = Absent, this is the correct config" )
            return $true
        }
        if ( -not $this.CurrentSettings -and $this.Ensure -eq 'Present' )
        {
            $this.NewVerboseMessage( "The NetAppQtree was not found and Ensure = Present" )
            return $false
        }
        if ( $this.CurrentSettings -and $this.Ensure -eq 'Absent' )
        {
            $this.NewVerboseMessage( "The NetAppQtree was found and Ensure = Absent" )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.Mode ) -eq $false -and $this.Mode -ne $this.CurrentSettings.Mode )
        {
            $this.NewVerboseMessage( "The NetAppQtree Mode is $( $this.CurrentSettings.Mode ) and should be: $( $this.Mode )" )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.SecurityStyle ) -eq $false -and $this.SecurityStyle -ne $this.CurrentSettings.SecurityStyle )
        {
            $this.NewVerboseMessage( "The NetAppQtree SecurityStyle is $( $this.CurrentSettings.SecurityStyle ) and should be: $( $this.SecurityStyle )" )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.ExportPolicy ) -eq $false -and $this.ExportPolicy -ne $this.CurrentSettings.ExportPolicy )
        {
            $this.NewVerboseMessage( "The NetAppQtree ExportPolicy is $( $this.CurrentSettings.ExportPolicy ) and should be: $( $this.ExportPolicy )" )
            return $false
        }
        if ( [string]::IsNullOrEmpty( $this.Oplocks ) -eq $false -and $this.Oplocks -ne $this.CurrentSettings.Oplocks )
        {
            $this.NewVerboseMessage( "The NetAppQtree Oplocks is $( $this.CurrentSettings.Oplocks ) and should be: $( $this.Oplocks )" )
            return $false
        }
        return $true
    }
}
