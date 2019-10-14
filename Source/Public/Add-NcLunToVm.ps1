function Add-NcLunToVm
{
    <#
    .SYNOPSIS
    This Command is used to add a Raw Device Mapping to a Virtual Machine
 
    .DESCRIPTION
    This Command uses both the VMware PowerCLI module and the NetApp ONTAP Toolkit in order to add the LUN to the VM.

    .EXAMPLE
    PS > Add-NcLunToVmAsRdm -Vserver cifsSvm01 -Path /vol/CompanyExchange01* -VmName CompanyExchange01

    This command will query the vserver for any luns beginning with ma02v and will then add them to the virtual machine.
    #>
    [CmdletBinding( DefaultParameterSetName = 'Set 1' )]
    [OutputType( [psobject], ParameterSetName = 'Set 1' )]
    Param(
        #The Name of the NetApp vServer that serves the LUN to the VMware Hosts.
        [Parameter( ParameterSetName = 'Set 1' )]
        [String]
        $Vserver
        ,
        #The Path to the LUN. You can use wildcards in order to select multiple LUN's. e.g. /vol/CompanyExchange01* Run the command 'Get-NcLun -Path /vol/<name>' to validate what you are trying to remove from.
        [Parameter( ParameterSetName = 'Set 1' )]
        [String]
        $Path
        ,
        #The name of the virtual machine as it shows up in the Get-VM commandlet. e.g. CompanyExchange01 You can use the command 'Get-VM -Name <vm name>' to validate the name.
        [Parameter( ParameterSetName = 'Set 1' )]
        [String]
        $VmName
    )
    begin
    {
        if ( -not $global:CurrentNcController )
        {
            throw 'You are not connected to a NetApp cluster use the command: "Connect-NcController <cluster Name>" to connect to a cluster.'
        }
        if ( -not $global:DefaultVIServer )
        {
            throw 'You are not connected to a VMware vCenter Sever use the commmand "Connect-ViServer <vCenter Name>" to connect.'
        }
    }
    process
    {
        $lunArr = Get-NcLun -Vserver $Vserver -Path $Path | Get-NcLunSerial | Select-Object Vserver, Path, CanonicalName, ConsoleDeviceName
        
        do
        {
            $title = "--- Luns ---"

            $message = "This script will be $(($lunArr | Measure-Object).count) lun(s) added to $VmName. Are you sure that you want to execute?"
            
            $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes I am good with the selected Luns."
            
            $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "TERMINATING Answer. This will stop the script."
            
            $ShowAll = New-Object System.Management.Automation.Host.ChoiceDescription "&ShowAll", "Display all of the Luns again."
            
            $options = [System.Management.Automation.Host.ChoiceDescription[]]( $Yes, $No, $ShowAll )
            
            $Decision = $host.ui.PromptForChoice( $title, $message, $options, 1 )

            if ( $Decision -eq 2 )
            {
                $lunArr
            }
            elseif ( $Decision -eq 1 )
            {
                throw "User Initiated Termination"
            }
        }
        until( $Decision -eq 0 )

        $vmObj = Get-VM -Name $VmName

        if ( -not $vmObj )
        {
            throw "No virtual machine could be found by the name: $VmName. Type the name as it appears in VMware vCenter. You can validate the name by running the command Get-VM -Name $VmName"
        }
        $currentVmRdms = $vmObj | Get-HardDisk -DiskType RawPhysical

        $vmHostLunsArr = Get-VMHost -Name $vmObj.VMHost | Get-ScsiLun

        foreach ( $lunObj in $lunArr )
        {
            if ( $vmHostLunsArr.CanonicalName -notcontains $lunObj.CanonicalName ) 
            {
                Write-Error -Message "Host $($vmObj.VMHost) does not see the LUN: $($lunObj.Name)" -ErrorAction Stop
            }
            else
            {
                $lunObj.ConsoleDeviceName = ( $vmHostLunsArr | Where-Object { $_.CanonicalName -eq $lunObj.CanonicalName } ).ConsoleDeviceName
            }
            if ( $currentVmRdms )
            {
                if ( $currentVmRdms.ScsiCanonicalName -contains $lunObj.CanonicalName )
                {
                    Write-Error -Message "The LUN is already presented to this VM" -ErrorAction Stop
                }
            }
            New-HardDisk -DiskType RawPhysical -VM $VmName -DeviceName $lunObj.ConsoleDeviceName
        }
    }
}