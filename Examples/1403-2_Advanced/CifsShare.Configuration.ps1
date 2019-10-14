Configuration NetAppCifsShareTest {

    Import-DSCResource -Name NetAppCifsShare -ModuleName insight

    Node 'localhost' {
        NetAppCifsShare Insight2019
        {
            Name                   = 'Insight_2019$'
            Path                   = '/'
            Vserver                = 'TestSVM'
            Controller             = 'cluster96'
            Credential             = $Node.Credential
            Ensure                 = 'Present'
            ShareProperties        = @( 'oplocks', 'browsable', 'showsnapshot', 'changenotify' )
            SymlinkProperties      = @( 'hide' )
            Comment                = 'Created for Start-Demo'
            OfflineFilesMode       = 'documents'
            MaxConnectionsPerShare = 24
        }
    }

}