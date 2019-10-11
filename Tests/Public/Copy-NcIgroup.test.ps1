[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute( 'PSAvoidUsingConvertToSecureStringWithPlainText', '', Justification = 'Creating test credentials requires converting plain text to secure string' )]
param()

Set-StrictMode -Version 2.0

[string]$functionName = 'Copy-NcIgroup'
[string]$functionPath = Join-Path -Path $( $PSScriptRoot -replace "Tests", "Source" ) -ChildPath "$functionName.ps1" -ErrorAction Stop

Describe "GIVEN $functionName and dependant functions are loaded into memory" {

    #Load required function into memory
    Import-Module dataONTAP
    Import-Module mockONTAP

    #Load testing function into memory
    . $functionPath

    Context 'WHEN a user passes a single object to Copy-NcIgroup' {
        $igroup = New-MockNcIgroup -Name TestIgroup -Vserver TestSVM -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi

        It 'THEN the function should throw' {
            { $igroup | Copy-NcIgroup -NewName 'NewIgroup' -Vserver TestSVM } | Should -Throw "You must be connected to a NetApp cluster in order for this function to work. Use Connect-NcController <ClusterName> and rerun the command"
        }
    }
    Context 'WHEN a user passes a single igroup to Copy-NcIgroup but there is an error during igroup creation' {
        $igroup = New-MockNcIgroup -Name TestIgroup -Vserver TestSVM -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        $NcController = New-MockNcController
        Mock -CommandName New-NcIgroup {
            throw 'Connection Lost'
        }
        It 'THEN the function should not throw' {
            { $igroup | Copy-NcIgroup -NewName 'NewIgroup' -Vserver TestSVM -Controller $NcController } | Should -Throw
        }
        It 'AND should call New-NcIgroup' {
            Assert-MockCalled -CommandName New-NcIgroup -Times 1
        }
    }
    Context 'WHEN a user passes a single igroup to Copy-NcIgroup without a Portset' {
        $igroup = New-MockNcIgroup -Name TestIgroup -Vserver TestSVM -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        $NcController = New-MockNcController
        Mock -CommandName New-NcIgroup {
            New-MockNcIgroup -Name $name -Vserver $VserverContext -Type $Type -Protocol $Protocol
        }
        Mock -CommandName Add-NcIgroupInitiator {
            New-MockNcIgroup -Name $name -Vserver $VserverContext -Type windows -Protocol iscsi -Initiator $initiator
        }
        Mock -CommandName Get-NcIgroup {
            New-MockNcIgroup -Name $name -Vserver $Vserver -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        }
        It 'THEN the function should not throw' {
            $igroup | Copy-NcIgroup -NewName 'NewIgroup' -Vserver TestSVM -Controller $NcController
        }
        It 'AND should call New-NcIgroup' {
            Assert-MockCalled -CommandName New-NcIgroup -Times 1
        }
        It 'AND should call Add-NcIgroupInitiator' {
            Assert-MockCalled -CommandName Add-NcIgroupInitiator -Times 1
        }
        It 'AND should call Get-NcIgroup' {
            Assert-MockCalled -CommandName Get-NcIgroup -Times 1
        }
    }
    Context 'WHEN a user passes a single igroup to Copy-NcIgroup with a pre-existing portset' {
        $igroup = New-MockNcIgroup -Name TestIgroup -Vserver TestSVM -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        $NcController = New-MockNcController
        Mock -CommandName New-NcIgroup {
            New-MockNcIgroup -Name $name -Vserver $VserverContext -Type $Type -Protocol $Protocol
        }
        Mock -CommandName Add-NcIgroupInitiator {
            New-MockNcIgroup -Name $name -Vserver $VserverContext -Type windows -Protocol iscsi -Initiator $initiator
        }
        Mock -CommandName Get-NcIgroup {
            New-MockNcIgroup -Name $name -Vserver $Vserver -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        }
        It 'THEN the function should not throw' {
            $igroup | Copy-NcIgroup -NewName 'NewIgroup' -Vserver TestSVM -Controller $NcController -PortSet TestPortset
        }
        It 'AND should call New-NcIgroup' {
            Assert-MockCalled -CommandName New-NcIgroup -Times 1
        }
        It 'AND should call Add-NcIgroupInitiator' {
            Assert-MockCalled -CommandName Add-NcIgroupInitiator -Times 1
        }
        It 'AND should call Get-NcIgroup' {
            Assert-MockCalled -CommandName Get-NcIgroup -Times 1
        }
    }
    Context 'WHEN a user passes a single igroup to Copy-NcIgroup with a new portset BUT there is an error during creation' {
        $igroup = New-MockNcIgroup -Name TestIgroup -Vserver TestSVM -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        $NcController = New-MockNcController
        Mock -CommandName New-NcPortset {
            New-MockNcPortset -PortsetName $name -PortsetType $Protocol -Vserver $VserverContext
        }
        Mock -CommandName Add-NcPortsetPort {
            throw 'Connection Error'
        }
        It 'THEN the function should not throw' {
            { $igroup | Copy-NcIgroup -NewName 'NewIgroup' -Vserver TestSVM -Controller $NcController -NewPortSetName TestPortset -NewPortSetPorts iscsi1, iscsi2 } | Should -Throw "There was an error during the creation of the Portset: Connection Error"
        }
        It 'AND should call New-NcPortset' {
            Assert-MockCalled -CommandName New-NcPortset -Times 1
        }
        It 'AND should call Add-NcPortsetPort two times' {
            Assert-MockCalled -CommandName Add-NcPortsetPort -Times 1
        }
    }
    Context 'WHEN a user passes a single igroup to Copy-NcIgroup with a new portset' {
        $igroup = New-MockNcIgroup -Name TestIgroup -Vserver TestSVM -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        $NcController = New-MockNcController
        Mock -CommandName New-NcPortset {
            New-MockNcPortset -PortsetName $name -PortsetType $Protocol -Vserver $VserverContext
        }
        Mock -CommandName Add-NcPortsetPort {
            New-MockNcPortset -PortsetName $name -PortsetType 'iscsi' -Vserver $VserverContext
        }
        Mock -CommandName New-NcIgroup {
            New-MockNcIgroup -Name $name -Vserver $VserverContext -Type $Type -Protocol $Protocol
        }
        Mock -CommandName Add-NcIgroupInitiator {
            New-MockNcIgroup -Name $name -Vserver $VserverContext -Type windows -Protocol iscsi -Initiator $initiator
        }
        Mock -CommandName Get-NcIgroup {
            New-MockNcIgroup -Name $name -Vserver $Vserver -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -Type windows -Portset TestPorset -Protocol iscsi
        }
        It 'THEN the function should not throw' {
            $igroup | Copy-NcIgroup -NewName 'NewIgroup' -Vserver TestSVM -Controller $NcController -NewPortSetName TestPortset -NewPortSetPorts iscsi1, iscsi2
        }
        It 'AND should call New-NcPortset' {
            Assert-MockCalled -CommandName New-NcPortset -Times 1
        }
        It 'AND should call Add-NcPortsetPort two times' {
            Assert-MockCalled -CommandName Add-NcPortsetPort -Times 2
        }
        It 'AND should call New-NcIgroup' {
            Assert-MockCalled -CommandName New-NcIgroup -Times 1
        }
        It 'AND should call Add-NcIgroupInitiator' {
            Assert-MockCalled -CommandName Add-NcIgroupInitiator -Times 1
        }
        It 'AND should call Get-NcIgroup' {
            Assert-MockCalled -CommandName Get-NcIgroup -Times 1
        }
    }
}