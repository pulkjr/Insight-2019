param(
    #This build will be done locally from a git repo
    [switch]$local
)
Set-StrictMode -Version Latest

#Requires -Version 5.0
#Requires -Modules @{ ModuleName="InvokeBuild"; ModuleVersion="5.5.1" }
#Requires -Modules @{ ModuleName="powershellget"; ModuleVersion="2.2.1" }
#Requires -Modules @{ ModuleName="PackageManagement"; ModuleVersion="1.4.5" }

Enter-Build {
    # Look for git and ensure it is present for versioning.
    if ( -not ( Get-Variable -Name git -Scope Script -ErrorAction Ignore ) )
    {
        if ( -not ( ( $Script:git = Get-Command -Name git.exe -ErrorAction Ignore ) ) )
        {
            throw 'git CLI is not found in PATH'
        }
    }

    #Load any build functions into memory
    foreach ( $buildScriptPath in $( Get-ChildItem -Path "$BuildRoot/build/" -Filter '*.ps1' ) )
    {
        . $buildScriptPath.FullName
    }
}

if ( $env:BUILD_ARTIFACTSTAGINGDIRECTORY )
{
    $Script:ArtifactsPath = $env:BUILD_ARTIFACTSTAGINGDIRECTORY
}
else
{
    $Script:ArtifactsPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$BuildRoot/artifacts" )
}

$Script:StagePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$BuildRoot/stage" )
$script:moduleName = 'Insight'

# Ensure the build agent has all the module needed to run build
task InstallDependencies {

    if ( -not ( Get-Module -ListAvailable pester ) )
    {
        Install-Module -Name pester -MinimumVersion 4.9.0 -Repository PSGallery -Force -AllowClobber
    }
    Import-Module -Name pester -MinimumVersion 4.9.0
}
# Remove previous artifacts and staged files
task Clean {

    if ( Test-Path -Path $Script:ArtifactsPath )
    {
        Remove-Item -Path $Script:ArtifactsPath -Recurse -Force
    }
    [void]( New-Item -ItemType Directory -Path $Script:ArtifactsPath -Force )

    if ( Test-Path -Path $Script:StagePath )
    {
        Remove-Item -Path $Script:StagePath -Recurse -Force
    }
    [void]( New-Item -ItemType Directory -Path $Script:StagePath -Force )
}
# Place the content of all associated ps1 files into a single 'psm1' file
task Stage InstallDependencies, Clean, ModuleVersion, {

    $moduleOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$Script:StagePath/$script:moduleName" )

    if ( -not ( Test-Path -Path $moduleOutputPath ) )
    {
        [void]( New-Item -Path $moduleOutputPath -ItemType Directory -Force )
    }
    if ( -not ( Test-Path -Path "$moduleOutputPath\Diagnostics" ) )
    {
        [void]( New-Item -Path "$moduleOutputPath\Diagnostics" -ItemType Directory -Force )
    }
    if ( -not ( Test-Path -Path "$moduleOutputPath\Diagnostics\Simple" ) )
    {
        [void]( New-Item -Path "$moduleOutputPath\Diagnostics\Simple" -ItemType Directory -Force )
    }
    Write-Build Yellow 'STAGE: Copying files to stage location'

    if ( -not ( Test-Path -Path "$moduleOutputPath\$script:moduleName.psm1" ) )
    {
        [void]( New-Item -ItemType File -Path "$moduleOutputPath\$script:moduleName.psm1" -Force )
    }
    Invoke-CopyFileListFromDevLocation -ModuleName $script:moduleName -ModuleOutputPath $moduleOutputPath

    Write-Build Yellow 'STAGE: Updating module version strings in relevant files'
    Invoke-UpdateModuleVersionInFile -ModuleName $script:moduleName -ModuleOutputPath $moduleOutputPath -Version $Script:ModuleVersion -RevisionNumber $Script:ModuleRevisionNumber -IsPreRelease:$Script:PreRelease

    Write-Build Yellow 'STAGE: Testing integrity of module manifest'
    [void]( Test-ModuleManifest -Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$moduleOutputPath/$script:moduleName.psd1" ) -ErrorAction Stop )
}
# Package the module into a nuget file for release
task Package ModuleVersion, {

    [System.IO.DirectoryInfo]$modulePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$Script:StagePath/$script:moduleName" )

    $module = Get-Module -Name $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$( $modulePath.FullName )/$( $script:moduleName ).psd1" ) -ListAvailable

    $fileName = "$( $module.Name ).$Script:ModuleSemVersionString"

    $nugetFilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$Script:ArtifactsPath/$fileName.nupkg" )
    if ( Test-Path -Path $nugetFilePath )
    {
        Remove-Item -Path $nugetFilePath -Force
    }
    Write-Build Yellow "PACKAGE: Creating Nuget package: $filename.nupkg"

    if ( -not ( Get-PackageProvider nuget ) )
    {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }
    if ( -not ( Get-PSRepository -Name local -ErrorAction 'SilentlyContinue' ) )
    {
        Register-PSRepository -Name Local -PublishLocation $Script:ArtifactsPath -SourceLocation $Script:ArtifactsPath -ErrorAction 'Continue'
    }
    Publish-Module -Path $modulePath.FullName -Repository local -confirm:$false -Force
}
# Conduct unit test for before pr is accepted
task UnitTest {

    $invokePesterParams = @{
        OutputFile   = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$Script:ArtifactsPath/TestResults.xml" )
        OutputFormat = 'NUnitXml'
        Script       = @{
            Path       = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$BuildRoot/tests/Unit*" )
            Parameters = @{
                BuildRoot = $BuildRoot
            }
        }
        Strict       = $true
        PassThru     = $true
        Verbose      = $false
        EnableExit   = $false
        Show         = 'All'
    }

    $testResults = Invoke-PesterJob @invokePesterParams

    assert ( $testResults.FailedCount -eq 0 ) "Failed $( $testResults.FailedCount ) unit tests"

}
# Version the module if the unit tests pass
task ModuleVersion -If ( -not ( Get-Variable -Name ModuleVersion -Scope Script -ErrorAction Ignore ) ) {
    #Parses the CHANGELOG.MD to get the base version string
    $moduleVersion = switch -Regex -File $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$BuildRoot/CHANGELOG.md" )
    {
        '### \[(\d+\.\d+\.\d+)\s*(.+)?\]$'
        {
            $Matches[1]

            break
        }
    }

    assert $moduleVersion

    #This will be true if the -Unreleased string is found
    $Script:Prerelease = $Matches.Count -eq 3

    $Matches.Clear()

    #If an online build, then use the build ID otherwise the number of commits in the branch
    $Script:ModuleRevisionNumber = $(
        if ( $env:BUILD_BUILDID )
        {
            $env:BUILD_BUILDID
        }
        else
        {
            exec { & $Script:git.Path -C "$BuildRoot" rev-list HEAD --count }
        }
    )

    #This will be the [System.Version] ( i.e. 3.4.0.115 )
    $Script:ModuleVersion = [version]::Parse( [string]::Format( '{0}.{1}', $moduleVersion, $Script:ModuleRevisionNumber ) )

    #This will be the string used in filenames
    $Script:ModuleSemVersionString = $Script:ModuleVersion.ToString( 3 )

    if ( $Script:Prerelease )
    {
        $Script:ModuleSemVersionString += "-build$Script:ModuleRevisionNumber"
    }

    Write-Build Yellow "MODULEVERSION: Using ModuleVersion number: $Script:ModuleSemVersionString ( $( $Script:ModuleVersion.ToString() ) )"
}
# Use the build number from the build agent rather than commit number
task BuildPackageVersion -If ( -not ( Get-Variable -Name BuildPackageVersion -Scope Script -ErrorAction Ignore ) ) {
    $version = switch -Regex -File $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath( "$BuildRoot/CHANGELOG.md" )
    {
        '### \[(\d+\.\d+\.\d+)\s*(.*)\]$'
        {
            $Matches[1]

            break
        }
    }

    $Matches.Clear()

    $revisionNumber = [System.DateTime]::UtcNow.ToString( 'yyMMddHHmm' )

    $Script:BuildPackageVersion = [version]::Parse( "$version.$revisionNumber" )

    assert $Script:BuildPackageVersion

    Write-Build Yellow "Using ( BuildPackage ) version number: $( $Script:BuildPackageVersion.ToString() )"
}

task . Stage, Package
