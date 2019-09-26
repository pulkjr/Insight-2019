<%
@"
[DscResource()]
class ${PLASTER_PARAM_ResourceName} : NetAppBase
{
    [DscProperty( Key, Mandatory )]
    [string] `$Name

    [DscProperty( Mandatory )]
    [String] `$Vserver

    hidden [${PLASTER_PARAM_CurrentSettingsType}] `$CurrentSettings #TODO: UPDATE TYPE

    [void]Remove${PLASTER_PARAM_ResourceName}()
    {
        `$this.NewVerboseMessage( 'Entered Remove${PLASTER_PARAM_ResourceName} Method' )

        if ( -not `$this.CurrentSettings )
        {
            `$this.NewVerboseMessage( ' - ${PLASTER_PARAM_ResourceName} does not exists, nothing to remove.' )
            return
        }
        #TODO: Add Remove Steps
        return
    }
    [void]New${PLASTER_PARAM_ResourceName}()
    {
        `$this.NewVerboseMessage( 'Entered New${PLASTER_PARAM_ResourceName} Method' )

        if ( `$this.CurrentSettings )
        {
            `$this.NewVerboseMessage( ' - ${PLASTER_PARAM_ResourceName} already exists and does not need to be created.' )
            return
        }
        #TODO: Add New Steps
        return
    }
    [void]Set${PLASTER_PARAM_ResourceName}()
    {
        `$this.NewVerboseMessage( 'Entered Set${PLASTER_PARAM_ResourceName} Method' )

        if ( -not `$this.CurrentSettings )
        {
            `$this.NewVerboseMessage( ' - ${PLASTER_PARAM_ResourceName} does not exists, nothing to set.' )
            return
        }
        #TODO: Add Configure Steps
        return
    }
    [void]Update${PLASTER_PARAM_ResourceName}()
    {
        `$this.NewVerboseMessage( 'Entered Update${PLASTER_PARAM_ResourceName} Method' )

        if ( -not `$this.CurrentSettings )
        {
            `$this.NewVerboseMessage( ' - ${PLASTER_PARAM_ResourceName} does not exists, nothing to update.' )
            return
        }
        #TODO: Add Update Steps
        return
    }
    [void]GetCurrentSettings()
    {
        `$this.ConnectONTAP()
        #TODO: Add GetCurrentSettings
    }
    [${PLASTER_PARAM_ResourceName}] Get()
    {
        `$this.NewVerboseMessage( 'Start Get Method' )

        `$this.GetCurrentSettings()

        if ( -not `$this.CurrentSettings )
        {
            return [${PLASTER_PARAM_ResourceName}]::new()
        }
        `$_returnShare = [${PLASTER_PARAM_ResourceName}]::new()
        `$_returnShare.Controller = `$this.Controller
        `$_returnShare.Credential = `$this.Credential
        `$_returnShare.Ensure = `$this.Ensure
        `$_returnShare.Vserver = `$this.CurrentSettings.Vserver

        #TODO: Add Get Method

        return `$_returnShare
    }
    [void] Set()
    {
        `$this.NewVerboseMessage( 'Start Set Method' )

        if ( `$this.Test() -eq `$true )
        {
            return
        }
        if ( `$this.Ensure -eq 'Absent' )
        {
            `$this.Remove${PLASTER_PARAM_ResourceName}()
            return
        }
        `$this.New${PLASTER_PARAM_ResourceName}()

        `$this.Set${PLASTER_PARAM_ResourceName}()

        `$this.Update${PLASTER_PARAM_ResourceName}()
    }
    [bool] Test()
    {
        `$this.GetCurrentSettings()

        if ( -not `$this.CurrentSettings -and `$this.Ensure -eq 'Absent' )
        {
            `$this.NewVerboseMessage( "The ${PLASTER_PARAM_ResourceName} was not found and Ensure = Absent, this is the correct config" )
            return `$true
        }
        if ( -not `$this.CurrentSettings -and `$this.Ensure -eq 'Present' )
        {
            `$this.NewVerboseMessage( "The ${PLASTER_PARAM_ResourceName} was not found and Ensure = Present" )
            return `$false
        }
        if ( `$this.CurrentSettings -and `$this.Ensure -eq 'Absent' )
        {
            `$this.NewVerboseMessage( "The ${PLASTER_PARAM_ResourceName} was found and Ensure = Absent" )
            return `$false
        }

        #TODO: Add Tests
        return `$false
    }
}
"@
%>
