$clusterName = '172.16.32.30'
$cred = [System.Management.Automation.PSCredential]::new( 'admin', $( ConvertTo-SecureString 'netapp123' -AsPlainText -Force ) )
Connect-NcController -Name $ClusterName -Credential $cred
if ( -not ( Get-NcVserver TestSVM ) )
{
    throw "Create a vserver named TestSVM with iscsi enabled"
}
if ( -not ( Get-NcNetInterface -Name iscsi1 -Vserver TestSVM ) ){
    New-NcNetInterface -Name iscsi1 -Vserver TestSVM -Role data -Node cluster96a -Port e0c -DataProtocols iscsi -Address 172.16.32.33 -Netmask 255.255.255.0
}
if ( -not ( Get-NcNetInterface -Name iscsi2 -Vserver TestSVM ) ){
    New-NcNetInterface -Name iscsi2 -Vserver TestSVM -Role data -Node cluster96a -Port e0c -DataProtocols iscsi -Address 172.16.32.34 -Netmask 255.255.255.0
}
if(-not ( Get-NcIgroup -Name Example ) ){
    New-NcIgroup -Name Example -Protocol iscsi -Type windows -VserverContext TestSVM
    Add-NcIgroupInitiator -Name Example -Initiator iqn.1998-01.com.vmware:5d9bf019-0f3b-42bc-976a-000c2981158f-39c384de -VserverContext TestSVM
}
if ( Get-NcIgroup -Name CopyIgroupScript -Vserver TestSVM ){
    Get-NcIgroup -Name CopyIgroupScript -Vserver TestSVM | Remove-NcIgroup
}
