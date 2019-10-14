Given 'a Windows Server with required PowerShell modules loaded' {
    Import-Module dataONTAP

    if ( Get-Module mockONTAP )
    {
        Remove-Module mockONTAP
    }
    $localDscResource = Get-DscResource -Name NetAppCifsShare -Module Insight

    $localDscResource[-1].Name | Should -Be 'NetAppCifsShare'

    $Username = 'admin'
    $Password = 'netapp123'
    $ClusterIP = '172.16.32.31'

    $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    $ncCredentials = New-Object System.Management.Automation.PSCredential( $Username, $secpasswd )

    $ncController = Connect-NcController -Name $ClusterIP -Credential $ncCredentials -Transient -https
}
When 'the (?<ResourceName>\S+) resources set method is executed' {
    param ( $ResourceName )
    Invoke-DscResource -Name $ResourceName -Method Set -ModuleName Insight -Property $resourceProperties
}
Then 'diagnostics tests against the (?<ResourceName>\S+) should all pass' {
    param ( $ResourceName )
    $diagTestResults = Invoke-Pester -Show Failed -PassThru -Script @{ Path = "$PSScriptRoot\..\Source\Diagnostics\Simple\$ResourceName.tests.ps1"
        Parameters                                                          = @{
            ResourceConfiguration = $resourceProperties
            NcController          = $ncController
        }
    }
    $diagTestResults.FailedCount | Should -BeLessThan 1
}
Then 'the (?<ResourceName>\S+) resource test method should respond true' {
    param ( $ResourceName )
    $dscTestResults = Invoke-DscResource -Name $ResourceName -Method Test -ModuleName Insight -Property $resourceProperties
    $dscTestResults | Should -BeTrue
}
