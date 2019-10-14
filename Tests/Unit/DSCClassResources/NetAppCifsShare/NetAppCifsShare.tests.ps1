param(
    $BuildRoot
)
$script:DSCModuleName = 'dscONTAP'
$script:DSCClassResourceName = 'NetAppCifsShare'

if ( $BuildRoot )
{
    $here = $BuildRoot
}
else
{
    $here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
    $here = Resolve-Path -Path "$here\..\.."
}


Describe "$script:DSCClassResourceName Module Tests" {
    Context 'Loading DSC Class Resource' {
        It "$script:DSCClassResourceName module should import" {
            Import-Module -Name ( Resolve-Path -Path ( "$here\Source\DSCClassResources\$DSCClassResourceName\$DSCClassResourceName.psd1" ) ) -verbose:$false -ErrorAction Stop -Force
        }
    }

    InModuleScope -ModuleName $script:DSCClassResourceName {
        #Load mock library
        Import-Module -Name mockONTAP -verbose:$false -Force

        $ResourceName = 'NetAppCifsShare'

        Context "$ResourceName Class" {
            It 'The class should instantiate using new() method without errors' {
                [NetAppCifsShare]::new()
            }
            Context 'RemoveNcCifsShare Method' {
                BeforeEach {
                    $Resource = [NetAppCifsShare]::new()
                    $Resource.Name = 'Share$'
                    $Resource.Path = '/NewVol/Share'
                    $Resource.Vserver = 'Vserver01'
                    $Resource.Controller = 'Cluster01'
                    $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
                    $Resource.Ensure = 'Absent'
                    $Resource.ShareProperties = @(
                        'oplocks'
                        'browsable'
                        'showsnapshot'
                    )
                    $Resource.SymlinkProperties = @(
                        'enable'
                        'hide'
                    )
                    $Resource.Comment = 'Share created with ticket IMW00001'
                    $Resource.OfflineFilesMode = 'none'
                    $Resource.VscanProfile = 'writes_only'
                    $Resource.MaxConnectionsPerShare = 10
                }
                Mock -CommandName Remove-NcCifsShare -MockWith {throw 'Remove!!'}

                It 'Should return if ensure is present' {
                    $Resource.Ensure = "Present"
                    $Resource.RemoveNetAppCifsShare()
                    Assert-MockCalled -CommandName Remove-NcCifsShare -Times 0 -Scope It
                }
                It 'Should return if current settings are missing' {
                    $Resource.RemoveNetAppCifsShare()
                    Assert-MockCalled -CommandName Remove-NcCifsShare -Times 0 -Scope It
                }
                It 'Should Call Remove-NcCifsShare' {
                    $Resource.CurrentSettings = New-MockNcCifsShare
                    { $Resource.RemoveNetAppCifsShare() } | Should -Throw 'Remove!!'
                    Assert-MockCalled -CommandName Remove-NcCifsShare -Times 1 -Scope It
                }
            }
        }
    }
}
