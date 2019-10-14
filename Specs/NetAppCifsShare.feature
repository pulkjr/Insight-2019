Feature: Manage Lifecycle of NetApp Cifs Shares

    Scenario: The Cifs Share does not exist and one is desired
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for NetAppCifsShare functional tests
        And Cifs share is missing
        And a configuration hashtable with ensure = present for a NetApp Cifs Share
        When the NetAppCifsShare resources set method is executed
        Then diagnostics tests against the NetAppCifsShare should all pass
        And the NetAppCifsShare resource test method should respond true

    Scenario: The Cifs Share exists but the configuration has been changed
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for NetAppCifsShare functional tests
        And a configuration hashtable with ensure = present for a NetApp Cifs Share
        When the NetAppCifsShare resources properties are updated
            | PropertyName      | PropertyValue          |
            | ShareProperties   | show_previous_versions |
            | SymlinkProperties | enable                 |
            | Comment           | Updated in Gherkin     |
            | OfflineFilesMode  | manual                 |
            | VscanProfile      | writes_only            |
        And the NetAppCifsShare resources set method is executed
        Then diagnostics tests against the NetAppCifsShare should all pass
        And the NetAppCifsShare resource test method should respond true

    Scenario: The Cifs Share does exists and it is not supposed to
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for NetAppCifsShare functional tests
        And a configuration hashtable with ensure = absent for a NetApp Cifs Share
        When the NetAppCifsShare resources set method is executed
        Then diagnostics tests against the NetAppCifsShare should all pass
        And the NetAppCifsShare resource test method should respond true
