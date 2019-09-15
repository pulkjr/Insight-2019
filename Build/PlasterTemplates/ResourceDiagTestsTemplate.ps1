param(
    [hashtable]
    $ResourceConfiguration,
    $NcController
)
<%
@"
Describe '${PLASTER_PARAM_ResourceName} Resource Configuration Tests' {
    `$CurrentSettings = Get-

    Context 'Resource Basic Configuration' {
        if ( `$ResourceConfiguration.Ensure -eq 'Absent' )
        {
            it 'Ensure is absent and Resource should be missing' {
                [string]::IsNullOrEmpty( `$CurrentSettings ) | Should -BeTrue
            }

            return
        }

    }
}
"@
%>
