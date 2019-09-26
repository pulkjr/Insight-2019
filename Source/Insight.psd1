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
    FormatsToProcess     = @('TypeData\Insight.Format.ps1xml')
    RootModule           = 'Insight.psm1'
    FunctionsToExport    = @(
        'Add-NcLunToVm'
        'Copy-NcIgroup'
        'Get-NcLunCanonicalName'
    )
    CmdletsToExport      = ''
    VariablesToExport    = ''
    AliasesToExport      = ''
    DscResourcesToExport = @(
        'NetAppQtree'
    )
    ModuleList           = @()
    FileList             = @(
        'dscONTAP.psd1'
        'dscONTAP.psm1'
        'Private/insight.class.ps1'
        'Private/Invoke-NcCommand.ps1'
        'Public/Add-NcLunToVm.ps1'
        'Public/Get-NcLunCanonicalName.ps1'
        'Public/Copy-NcIgroup.ps1'
    )
    PrivateData          = @{
        BuildNumber = '0'
        PSData      = @{
            Tags                       = @('DesiredStateConfiguration', 'DSC', 'NetApp', 'NTAP')
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

