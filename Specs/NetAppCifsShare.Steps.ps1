Given 'the test environment is configured for NetAppCifsShare functional tests' {
    $ncController.Address | Should -Be $ClusterIP
}
Given 'Cifs share is missing' {
    $share = Get-NcCifsShare -Name NetAppCifsShare_GherkinTest$ -VserverContext TestSVM -Controller $ncController

    if ( $share )
    {
        Remove-NcCifsShare -Name NetAppCifsShare_GherkinTest$ -VserverContext TestSVM -Confirm:$False -Controller $ncController
    }
}
Given 'a configuration hashtable with ensure = (?<Ensure>\S+) for a NetApp Cifs Share' {
    param ( $Ensure )

    $resourceProperties = @{
        Name                   = 'NetAppCifsShare_GherkinTest$'
        Path                   = '/'
        Vserver                = 'TestSVM'
        Controller             = $ClusterIP
        Credential             = $ncCredentials
        Ensure                 = $Ensure
        ShareProperties        = @( 'oplocks', 'browsable', 'showsnapshot', 'changenotify' )
        SymlinkProperties      = @( 'hide' )
        Comment                = 'Insight Automated Build from Specs'
        OfflineFilesMode       = 'documents'
        MaxConnectionsPerShare = 24
    }
}
When 'the NetAppCifsShare resources properties are updated' {
    param ( $table )
    foreach ( $row in $table )
    {
        if ( $resourceProperties.ContainsKey( $row.PropertyName ) )
        {
            if ( $row.PropertyName -in @( 'ShareProperties', 'SymlinkProperties' ) )
            {
                $row.PropertyValue = @( $row.PropertyValue )
            }
            else
            {
                $resourceProperties.$( $row.PropertyName ) = $row.PropertyValue
            }
        }
        else
        {
            $resourceProperties.Add( $row.PropertyName, $row.PropertyValue )
        }
    }
}
