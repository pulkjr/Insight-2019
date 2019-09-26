param(
    $BuildRoot
)
$script:DSCModuleName = 'dscONTAP'
$script:DSCClassResourceName = 'NetAppBase'

if ( $BuildRoot )
{
    $here = $BuildRoot
}
else
{
    $here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
    $here = Resolve-Path -Path "$here\..\.."
}


Describe "Given the $script:DSCClassResourceName Module" {
    Context 'Loading DSC Class Resource' {
        It "$script:DSCClassResourceName module should import" {
            Import-Module -Name ( Resolve-Path -Path ( "$here\Source\DSCClassResources\$DSCClassResourceName\$DSCClassResourceName.psd1" ) ) -verbose:$false -ErrorAction Stop -Force
        }
    }

    InModuleScope -ModuleName $script:DSCClassResourceName {
        #Load mock library
        Import-Module -Name mockONTAP -verbose:$false -Force

        $ResourceName = 'NetAppBase'

        Context "$ResourceName Class" {
            It 'The class should instantiate using new() method without errors' {
                [NetAppBase]::new()
            }
        }
        Context "WHEN the NewVerboseMessage method is used with a message of hello" {
            mock Get-Date {
                return '2000-00-00_00-00-00'
            }
            mock Write-Information {
                param( $MessageData )
                throw $MessageData
            }

            it 'THEN the output should be "2000-00-00_00-00-00:hello"' {
                $resource = [NetAppBase]::new()
                { $resource.NewVerboseMessage( 'hello' ) } | Should -Throw "2000-00-00_00-00-00:hello"
                Get-Date
                Assert-MockCalled -CommandName Get-Date -Times 1 -Scope it
            }
        }
        Context 'WHEN the ConnectONTAP Method is called AND Connect-NcController returns null.' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true

            mock Connect-NcController { $null }

            It 'THEN it should throw an error' {
                { $Resource.ConnectONTAP() } | Should -Throw "Unable to connect to Cluster 'cluster01' using credentials 'test' exception"

                Assert-MockCalled -CommandName Connect-NcController
            }
        }
        Context 'WHEN the ConnectONTAP Method is called AND Connect-NcController returns the object.' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true

            Mock Connect-NcController {
                param(
                    $Name,
                    [ValidateSet( 443, 80 )]
                    $Port,
                    $Credential,
                    [switch]$HTTPS,
                    [switch]$HTTP,
                    $Transient,
                    $Vserver,
                    $Timeout
                )
                mockONTAP\New-MockNcController @PSBoundParameters
            }

            It 'THEN it should execute without errors' {

                $Resource.ConnectONTAP()

                Assert-MockCalled -CommandName Connect-NcController -Scope it -Times 1
            }
            It 'THEN the property NcController should contain the connection' {

                $Resource.NcController | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
            }
            It 'AND a connection was previously established. THEN the method should return without calling Connect-NcController' {

                { $Resource.ConnectONTAP() }

                Assert-MockCalled -CommandName Connect-NcController -Scope it -Times 0
            }
            It 'AND a connection was previously established. THEN the method should write information about the connection previous establishment' {
                Mock Write-Information {
                    if ($MessageData -like "*Using Cached Connection to cluster01...")
                    {
                        throw 'CACHED'
                    }
                }

                { $Resource.ConnectONTAP() } | Should -Throw 'CACHED'

                Assert-MockCalled -CommandName Connect-NcController -Scope it -Times 0
            }

        }
        Context 'WHEN the ConnectONTAP Method is called AND the pscredential object is empty' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [pscredential]::Empty
            $Resource.HTTPS = $true
            It 'THEN the method should throw an error' {
                { $Resource.ConnectONTAP() } | Should -Throw "Invalid credential object provided. Ensure correct PSCredential object type."
            }
        }
        Context "WHEN the ConvertSizeToBytesDecimal method is used" {
            BeforeEach {
                $resource = [NetAppBase]::new()
            }
            It 'AND the input is 2048 THEN the output should be 2048' {
                $resource.ConvertSizeToBytesDecimal( 2048, 'b' ) | Should -Be 2048
            }
            It 'AND the input is 2kb THEN the output should be 2048' {
                $resource.ConvertSizeToBytesDecimal( 2, 'kb' ) | Should -Be 2048
            }
            It 'AND the input is 2mb THEN the output should be 2097152' {
                $resource.ConvertSizeToBytesDecimal( 2, 'mb' ) | Should -Be 2097152
            }
            It 'AND the input is 2gb THEN the output should be 2147483648' {
                $resource.ConvertSizeToBytesDecimal( 2, 'gb' ) | Should -Be 2147483648
            }
            It 'AND the input is 2tb THEN the output should be 2199023255552' {
                $resource.ConvertSizeToBytesDecimal( 2, 'tb' ) | Should -Be 2199023255552
            }
        }
        Context "WHEN the CompareSizes method is used" {
            BeforeEach {
                $resource = [NetAppBase]::new()
            }
            It 'AND the input is 2048 & 2048 THEN the output should be True' {
                $resource.CompareSizes( '2048', '2048' ) | Should -BeTrue
            }
            It 'AND the input is 2048 & 2044 THEN the output should be False' {
                $resource.CompareSizes( '2048', '2044' ) | Should -BeFalse
            }
            It 'AND the input is 2mb & 2048kb THEN the output should be True' {
                $resource.CompareSizes( '2mb', '2048kb' ) | Should -BeTrue
            }
        }
        Context 'WHEN the Get Method is executed' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true
            It 'THEN "this" should be returned' {
                ( $Resource.Get() ).GetType().Name | Should -Be 'NetAppBase'
            }
        }
        Context 'WHEN the Test Method is executed' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true
            It 'THEN it should return true' {
                $Resource.Test() | Should -BeTrue
            }
        }
        Context 'WHEN the WaitNcJob Method is executed AND the job does not exist' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true

            Mock Get-NcJob {
                return
            }
            It 'THEN it should return' {
                $Resource.WaitNcJob( [DataONTAP.C.Types.Job.JobInfo]::new(), 100 )
                Assert-MockCalled -CommandName Get-NcJob -Times 1 -Scope it
            }
        }
        Context 'WHEN the WaitNcJob Method is executed AND the job exists BUT is running for 3 Iterations' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true

            $script:itter = 0
            mock Start-Sleep {
                $script:itter++
            }
            Mock Get-NcJob {
                if ( $script:itter -lt 3 )
                {
                    New-MockNcJob -JobState 'running'
                }
                else
                {
                    New-MockNcJob -JobState 'Succeeded'
                }
            }
            $job = [DataONTAP.C.Types.Job.JobInfo]::new()
            $job.JobVserver = 'TestSVM'
            It 'THEN it should call Get-NcJob 3 times' {
                $Resource.WaitNcJob( $job , 100 )
                Assert-MockCalled -CommandName Get-NcJob -Times 3 -Scope it
            }
        }
        Context 'WHEN the WaitNcJob Method is executed AND the job exists BUT is running over 10 Iterations' {
            $Resource = [NetAppBase]::new()
            $Resource.Controller = 'cluster01'
            $Resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $Resource.HTTPS = $true

            Mock Get-NcJob {
                New-MockNcJob -JobState 'running'
            }
            Mock Write-Information {
                if ( $MessageData -match 'The Job has not completed but the max retry count was hit' )
                {
                    throw 'Still Running'
                }
            }
            $job = [DataONTAP.C.Types.Job.JobInfo]::new()
            $job.JobVserver = 'TestSVM'
            It 'THEN it should call Get-NcJob 10 times' {
                { $Resource.WaitNcJob( $job , 10 ) } | Should -Throw 'Still Running'
                Assert-MockCalled -CommandName Get-NcJob -Times 10 -Scope it
            }
        }
    }
}
