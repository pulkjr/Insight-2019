param(
    [hashtable]
    $ResourceConfiguration,
    $NcController
)
Describe 'NetAppQtree Resource Configuration Tests' {
    $_qtreeParameters = @{
        Volume         = $ResourceConfiguration['Volume']
        Qtree          = $ResourceConfiguration['Name']
        VserverContext = $ResourceConfiguration['Vserver']
        Controller     = $NcController
    }
    $CurrentSettings = Get-NcQtree @_qtreeParameters

    Context 'Resource Basic Configuration' {
        if ( $ResourceConfiguration.Ensure -eq 'Absent' )
        {
            it 'Ensure is absent and resource should be missing' {
                [string]::IsNullOrEmpty( $CurrentSettings ) | Should -BeTrue
            }
            return
        }
        if ( $ResourceConfiguration.Ensure -eq 'Present' )
        {
            it 'Ensure is present and resource should be present' {
                [string]::IsNullOrEmpty( $CurrentSettings ) | Should -BeFalse
            }
        }
        if ( $ResourceConfiguration.ContainsKey( 'Mode' ) )
        {
            it "Qtree mode is $( $CurrentSettings.Mode ) and should be $( $ResourceConfiguration['Mode'] )" {
                $CurrentSettings.Mode | Should -Be $ResourceConfiguration['Mode']
            }
        }
        if ( $ResourceConfiguration.ContainsKey( 'SecurityStyle' ) )
        {
            it "Qtree SecurityStyle is $( $CurrentSettings.SecurityStyle ) and should be $( $ResourceConfiguration['SecurityStyle'] )" {
                $CurrentSettings.SecurityStyle | Should -Be $ResourceConfiguration['SecurityStyle']
            }
        }
        if ( $ResourceConfiguration.ContainsKey( 'ExportPolicy' ) )
        {
            it "Qtree ExportPolicy is $( $CurrentSettings.ExportPolicy ) and should be $( $ResourceConfiguration['ExportPolicy'] )" {
                $CurrentSettings.ExportPolicy | Should -Be $ResourceConfiguration['ExportPolicy']
            }
        }
        if ( $ResourceConfiguration.ContainsKey( 'Oplocks' ) )
        {
            it "Qtree Oplocks is $( $CurrentSettings.Oplocks ) and should be $( $ResourceConfiguration['Oplocks'] )" {
                $CurrentSettings.Oplocks | Should -Be $ResourceConfiguration['Oplocks']
            }
        }
    }
}
