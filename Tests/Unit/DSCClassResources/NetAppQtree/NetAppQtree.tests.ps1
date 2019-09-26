param(
    $BuildRoot
)
$script:DSCModuleName = 'dscONTAP'
$script:DSCClassResourceName = 'NetAppQtree'

if ( $BuildRoot )
{
    $here = $BuildRoot
}
else
{
    $here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
    $here = Resolve-Path -Path "$here\..\.."
}

Import-Module DataONTAP
$moduleName = ( [guid]::NewGuid() ).Guid
Describe "GIVEN the $script:DSCClassResourceName Module" {
    Context 'WHEN the user imports the module' {
        It "THEN the $script:DSCClassResourceName module should import without errors" {
            $moduleStr = [System.Text.StringBuilder]::new( $( Get-Content -Path "$here\Source\DSCClassResources\NetAppBase\NetAppBase.psm1" -Raw -Force ) )
            $moduleStr.AppendLine().Append( $( Get-Content -Path "$here\Source\DSCClassResources\$DSCClassResourceName\$DSCClassResourceName.psm1" -Raw -Force ) )
            $moduleContent = [scriptblock]::Create( $moduleStr )
            New-Module -ScriptBlock $moduleContent -Name $moduleName | Import-Module -Force
        }
    }

    InModuleScope -ModuleName $moduleName {
        #Load mock library
        Import-Module -Name mockONTAP -verbose:$false -Force

        $ResourceName = 'NetAppQtree'

        Context "WHEN the $ResourceName Class is instantiated" {
            It 'THEN the constructor should be executed without errors' {
                [NetAppQtree]::new()
            }
        }
        Context "WHEN the RemoveNetAppQtree method is called AND there is no Qtree on the system." {
            $resource = [NetAppQtree]::new()
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Remove-NcQtree -MockWith {
                $null
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "* - Qtree does not exists and does not need to be removed." )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the RemoveNetAppQtree method should return without calling Remove-NcQtree' {
                $resource.RemoveNetAppQtree()
                Assert-MockCalled -CommandName Remove-NcQtree -Times 0 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the RemoveNetAppQtree method is called AND there is a Qtree on the system." {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume'
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Remove-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $Force | Should -BeTrue
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "* - Qtree exists and must be absent, removing now." )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the RemoveNetAppQtree method should return calling Remove-NcQtree with the correct properties one time' {
                $resource.RemoveNetAppQtree()
                Assert-MockCalled -CommandName Remove-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the NewNetAppQtree method is called AND there is a Qtree on the system." {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume'
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName New-NcQtree -MockWith {
                $null
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "* - Qtree already exists and does not need to be created." )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the NewNetAppQtree method should return not call New-NcQtree' {
                $resource.NewNetAppQtree()
                Assert-MockCalled -CommandName New-NcQtree -Times 0 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the NewNetAppQtree method is called AND there is not a Qtree on the system." {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Mode = "644"
            $resource.Oplocks = "enabled"
            $resource.SecurityStyle = "unix"
            $resource.ExportPolicy = 'RemoveExportPolicy'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName New-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $Mode | Should -Be "644"
                $Oplocks | Should -Be "enabled"
                $SecurityStyle | Should -Be "unix"
                $ExportPolicy | Should -Be "RemoveExportPolicy"
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "* - No Qtree found on SVM. Creating a new qtree now." )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the NewNetAppQtree method should call New-NcQtree once with the correct properties' {
                $resource.NewNetAppQtree()
                Assert-MockCalled -CommandName New-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the SetNetAppQtree method is called AND the Mode Property is incorrectly configured" {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Mode = "644"
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -Mode '755'
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Set-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $Mode | Should -Be "644"
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*- The qtree mode is set incorrectly, updating now" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the SetNetAppQtree method should call Set-NcQtree once with the correct properties' {
                $resource.SetNetAppQtree()
                Assert-MockCalled -CommandName Set-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the SetNetAppQtree method is called AND the SecurityStyle Property is incorrectly configured" {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.SecurityStyle = "ntfs"
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -SecurityStyle 'unix'
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Set-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $SecurityStyle | Should -Be "ntfs"
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*- The qtree SecurityStyle is set incorrectly, updating now" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the SetNetAppQtree method should call Set-NcQtree once with the correct properties' {
                $resource.SetNetAppQtree()
                Assert-MockCalled -CommandName Set-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the SetNetAppQtree method is called AND the ExportPolicy Property is incorrectly configured" {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.ExportPolicy = "default"
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -ExportPolicy 'WindowsOnly'
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Set-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $ExportPolicy | Should -Be "default"
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*- The qtree ExportPolicy is set incorrectly, updating now" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the SetNetAppQtree method should call Set-NcQtree once with the correct properties' {
                $resource.SetNetAppQtree()
                Assert-MockCalled -CommandName Set-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the SetNetAppQtree method is called AND the Oplocks Property is incorrectly configured ( Enabled )" {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Oplocks = "enabled"
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -Oplocks 'disabled'
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Set-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $EnableOplocks | Should -BeTrue
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*- The qtree Oplocks is set incorrectly, updating now" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the SetNetAppQtree method should call Set-NcQtree once with the correct properties' {
                $resource.SetNetAppQtree()
                Assert-MockCalled -CommandName Set-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the SetNetAppQtree method is called AND the Oplocks Property is incorrectly configured ( Disabled )" {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Oplocks = "disabled"
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $resource.CurrentSettings = New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -Oplocks 'enabled'
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Set-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                $DisableOplocks | Should -BeTrue
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*- The qtree Oplocks is set incorrectly, updating now" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the SetNetAppQtree method should call Set-NcQtree once with the correct properties' {
                $resource.SetNetAppQtree()
                Assert-MockCalled -CommandName Set-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the GetCurrentSettings method is called AND there is a Qtree on the system." {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            Mock -CommandName Get-NcQtree -MockWith {
                $Volume | Should -Be 'RemoveVolume'
                $Qtree | Should -Be 'RemoveQtree'
                $VserverContext | Should -Be 'QtreeTestSVM'
                $Controller | Should -BeOfType [NetApp.Ontapi.Filer.C.NcController]
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume'
            }
            It 'THEN the GetCurrentSettings method should call the Get-NcQtree with correct parameters' {
                $resource.GetCurrentSettings()
                $resource.CurrentSettings.Volume | Should -Be 'RemoveVolume'
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
        }
        Context "WHEN the Test method is called, AND there is NO Qtree, AND ensure is Absent " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Absent'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                return
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree was not found and Ensure = Absent, this is the correct config" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return True' {
                $resource.Test() | Should -BeTrue
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is NO Qtree, AND ensure is Present " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Present'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                return
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree was not found and Ensure = Present" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return False' {
                $resource.Test() | Should -BeFalse
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is a Qtree, AND ensure is Absent " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Absent'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume'
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree was found and Ensure = Absent" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return False' {
                $resource.Test() | Should -BeFalse
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is a Qtree, AND ensure is Present, AND Mode is incorrect " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Present'
            $resource.Mode = '644'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -Mode '755'
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree Mode is 755 and should be: 644" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return False' {
                $resource.Test() | Should -BeFalse
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is a Qtree, AND ensure is Present, AND SecurityStyle is incorrect " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Present'
            $resource.SecurityStyle = 'unix'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -SecurityStyle 'ntfs'
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree SecurityStyle is ntfs and should be: unix" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return False' {
                $resource.Test() | Should -BeFalse
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is a Qtree, AND ensure is Present, AND ExportPolicy is incorrect " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Present'
            $resource.ExportPolicy = 'default'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -ExportPolicy 'WindowsOnly'
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree ExportPolicy is WindowsOnly and should be: default" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return False' {
                $resource.Test() | Should -BeFalse
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is a Qtree, AND ensure is Present, AND Oplocks is incorrect " {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Present'
            $resource.Oplocks = 'enabled'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            $script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Get-NcQtree -MockWith {
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -Oplocks 'disabled'
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree Oplocks is disabled and should be: enabled" )
                {
                    $script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN the test method should return False' {
                $resource.Test() | Should -BeFalse
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
            It 'AND should go through the correct code path' {
                $script:CodePath | Should -Be 'Called Correctly'
            }
        }
        Context "WHEN the Test method is called, AND there is a Qtree, AND ensure is Present, AND all properties are correct" {
            $resource = [NetAppQtree]::new()
            $resource.Volume = 'RemoveVolume'
            $resource.Name = 'RemoveQtree'
            $resource.Vserver = 'QtreeTestSVM'
            $resource.Controller = 'Cluster01'
            $resource.Ensure = 'Present'
            $resource.Oplocks = 'enabled'
            $resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            $resource.NcController = New-MockNcController
            Mock -CommandName Get-NcQtree -MockWith {
                New-MockNcQtree -Qtree 'RemoveQtree' -Volume 'RemoveVolume' -Oplocks 'enabled'
            }
            Mock -CommandName Write-Information -MockWith {
                if ( $MessageData -like "*The NetAppQtree was not found and Ensure = Absent, this is the correct config"  )
                {
                    Throw 'Incorrect Code Path Taken'
                }
            }
            It 'THEN the test method should return True' {
                $resource.Test() | Should -BeTrue
                Assert-MockCalled -CommandName Get-NcQtree -Times 1 -Scope it
            }
        }

    }
}
