param(
    $BuildRoot
)
$script:DSCModuleName = 'dscONTAP'
<%
@"
`$script:DSCClassResourceName = '${PLASTER_PARAM_ResourceName}'
"@
%>

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

        <%
        @"
        `$ResourceName = '${PLASTER_PARAM_ResourceName}'

        Context "WHEN the `$ResourceName Class is instantiated" {
            It 'THEN no errors should be thrown' {
                [${PLASTER_PARAM_ResourceName}]::new()
            }
        }
        Context "WHEN the Test method is called AND no CurrentSettings exist AND Ensure = Absent" {
            `$resource = [${PLASTER_PARAM_ResourceName}]::new()
            `$resource.Controller = 'controller01'
            `$resource.Ensure = 'Absent'
            `$resource.Vserver = 'TestSVM'
            `$resource.Target = '/vol/RemoveVol/RemoveQtree'
            `$resource.Credential = [System.Management.Automation.PSCredential]::new( 'test', $( ConvertTo-SecureString 'MySecretPassword' -AsPlainText -Force ) )
            `$script:CodePath = 'Incorrect Code Path'
            Mock -CommandName Write-Information -MockWith {
                if ( `$MessageData -like "*The ${PLASTER_PARAM_ResourceName} was not found and Ensure = Absent, this is the correct config" )
                {
                    `$script:CodePath = 'Called Correctly'
                }
            }
            It 'THEN Test should return true' {
                `$resource.Test() | Should -BeTrue
            }
            It 'AND should go through correct code path' {
                `$script:CodePath | Should -Be 'Called Correctly'
            }
        }
"@
        %>
    }
    Remove-Module -Name $moduleName
}
