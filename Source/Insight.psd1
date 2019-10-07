@{
    ModuleVersion        = '0.0.1'
    GUID                 = '082bf0fa-ee76-4124-9855-30fadfecedea'
    Author               = @(
        'Joseph Pulk'
        'Jason Cole'
    )
    CompanyName          = 'NetApp'
    Copyright            = '(c) 2019 NetApp Corporation. All rights reserved.'
    Description          = 'Module for demonstrating PowerShell capabilities with NetApp and VMware integrations'
    PowerShellVersion    = '5.0'
    CLRVersion           = '4.0'
    RequiredModules      = 'DataONTAP'
    TypesToProcess       = @()
    FormatsToProcess     = @('Insight.Format.ps1xml')
    RootModule           = 'Insight.psm1'
    FunctionsToExport    = @(
        'Add-NcLunToVm'
        'Copy-NcIgroup'
        'Get-NcLunCanonicalName'
        'Get-NcAggrSpaceInfo'
    )
    CmdletsToExport      = ''
    VariablesToExport    = ''
    AliasesToExport      = ''
    DscResourcesToExport = @(
        'NetAppQtree'
    )
    ModuleList           = @()
    FileList             = @(
        'Insight.psd1'
        'Insight.psm1'
        'Insight.Format.ps1xml'
        'Diagnostics\NetAppQtree.tests.ps1'
    )
    PrivateData          = @{
        BuildNumber = '0'
        PSData      = @{
            Tags                       = @('DesiredStateConfiguration', 'NetApp', 'NTAP')
            ExternalModuleDependencies = @(
                'DataONTAP'
            )
            ReleaseNotes               = 'initial release'
            Category                   = ''
            IconUri                    = ''
            ProjectUri                 = ''
            LicenseUri                 = ''
            Prerelease                 = ''
        }
    }
}

