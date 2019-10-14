param(
    [hashtable]
    $ResourceConfiguration,
    $NcController
)
Describe 'NetAppCifsShare Resource Configuration Tests' {
    [DataONTAP.C.Types.Cifs.CifsShare]$CurrentSettings = Get-NcCifsShare -Name $ResourceConfiguration['Name'] -VserverContext $ResourceConfiguration['Vserver'] -Controller $NcController

    Context 'Resource Basic Configuration' {
        if ( $ResourceConfiguration['Ensure'] -eq 'Absent' )
        {
            it 'Ensure is absent and Resource should be missing' {
                [string]::IsNullOrEmpty( $CurrentSettings ) | Should -BeTrue
            }

            return
        }
        if ( $ResourceConfiguration['Ensure'] -eq 'Present' )
        {
            it 'The Share was not found and Ensure = Present' {
                $CurrentSettings | Should -BeOfType [DataONTAP.C.Types.Cifs.CifsShare]
            }
            it $( [string]::Format( 'The Name is supposed to be: {0} but is: {1}', $ResourceConfiguration['Name'], $CurrentSettings.ShareName ) ) {
                $CurrentSettings.ShareName | Should -Be $ResourceConfiguration['Name']
            }
        }

        it $( [string]::Format( 'The Path is supposed to be: {0} but is: {1}', $ResourceConfiguration['Path'], $CurrentSettings.Path ) ) {
            $CurrentSettings.Path | Should -Be $ResourceConfiguration['Path']
        }

        if ( $ResourceConfiguration.Comment )
        {
            it $( [string]::Format( 'Comment is supposed to be: {0} but is: {1}', $ResourceConfiguration.Comment, $CurrentSettings.Comment ) ) {
                $CurrentSettings.Comment | Should -Be $ResourceConfiguration['Comment']
            }
        }
        if ( $ResourceConfiguration.ContainsKey( 'OfflineFilesMode' ) )
        {
            it $( [string]::Format( 'OfflineFilesMode is supposed to be: {0} but is: {1}', $ResourceConfiguration.OfflineFilesMode, $CurrentSettings.OfflineFilesMode ) ) {
                $CurrentSettings.OfflineFilesMode | Should -Be $ResourceConfiguration.OfflineFilesMode
            }
        }
        if ( $ResourceConfiguration.ContainsKey( 'VscanProfile' ) )
        {
            it $( [string]::Format( 'VscanProfile is supposed to be: {0} but is: {1}', $ResourceConfiguration.VscanProfile, $CurrentSettings.VscanFileopProfile ) ) {
                $CurrentSettings.VscanFileopProfile | Should -Be $ResourceConfiguration.VscanProfile
            }
        }
        if ( $ResourceConfiguration.MaxConnectionsPerShare -gt 0 )
        {
            it $( [string]::Format( 'MaxConnectionsPerShare is supposed to be: {0} but is: {1}', $ResourceConfiguration.MaxConnectionsPerShare, $CurrentSettings.MaxConnectionsPerShare ) ) {
                $CurrentSettings.MaxConnectionsPerShare | Should -Be $ResourceConfiguration.MaxConnectionsPerShare
            }
        }
        if ( $ResourceConfiguration.ShareProperties )
        {
            foreach ( $_shareProperty in $ResourceConfiguration.ShareProperties )
            {
                it $( [string]::Format( 'ShareProperties should contain: {0}', $_shareProperty ) ) {
                    $_shareProperty | Should -BeIn $CurrentSettings.ShareProperties
                }
            }
        }
        if ( $ResourceConfiguration.SymlinkProperties )
        {
            foreach ( $_symlinkProperty in $ResourceConfiguration.SymlinkProperties )
            {
                it $( [string]::Format( 'SymlinkProperties should contain: {0}', $_symlinkProperty ) ) {
                    $_symlinkProperty | Should -BeIn $CurrentSettings.SymlinkProperties
                }

            }
        }

    }
}
