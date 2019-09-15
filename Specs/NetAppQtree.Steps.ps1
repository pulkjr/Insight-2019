Given 'the test environment is configured for NetAppQtree functional tests' {
    $ncController.Address | Should -Be $ClusterIP
    if ( -not $( Get-NcVserver -Name TestSVM -Controller $ncController ) )
    {
        Throw 'Test environment does not contain a SVM with the name of TestSVM'
    }
    if ( -not $( Get-NcVol -Name GherkinTests -Vserver TestSVM -Controller $ncController ) )
    {
        [string]$aggr = ( Get-NcAggr -Controller $ncController | Where-Object { -not $_.AggrRaidAttributes.HasLocalRoot } )[-1].Name
        New-NcVol -Name GherkinTests -VserverContext TestSVM -Size 1g -JunctionPath /GherkinTests -SpaceGuarantee none -PercentSnapshotReserve 0 -Controller $ncController -Aggregate $aggr
    }
}
Given 'Qtree is missing' {
    $qtree = Get-NcQtree -Volume GherkinTests -Qtree QtreeResourceTest -VserverContext TestSVM -Controller $ncController

    if ( $qtree )
    {
        Remove-NcQtree -Volume GherkinTests -Qtree QtreeResourceTest -Force -VserverContext TestSVM -Confirm:$False -Controller $ncController
    }
}
Given 'a configuration hashtable with ensure = (?<Ensure>\S+) for a NetApp Qtree' {
    param ( $Ensure )

    $resourceProperties = @{
        Name          = 'QtreeResourceTest'
        Volume        = 'GherkinTests'
        Vserver       = 'TestSVM'
        Controller    = $ClusterIP
        Credential    = $ncCredentials
        Ensure        = $Ensure
        Oplocks       = 'enabled'
        SecurityStyle = 'ntfs'
    }
}
When 'the NetAppQtree resources properties are updated' {
    param ( $table )
    foreach ( $row in $table )
    {
        if ( $resourceProperties.ContainsKey( $row.PropertyName ) )
        {

            $resourceProperties.$( $row.PropertyName ) = $row.PropertyValue

        }
        else
        {
            $resourceProperties.Add( $row.PropertyName, $row.PropertyValue )
        }
    }
}
