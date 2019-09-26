Feature: Manage Lifecycle of NetApp Qtree

    Scenario: The Qtree does not exist and one is desired
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for NetAppQtree functional tests
        And Qtree is missing
        And a configuration hashtable with ensure = present for a NetApp Qtree
        When the NetAppQtree resources set method is executed
        Then diagnostics tests against the NetAppQtree should all pass
        And the NetAppQtree resource test method should respond true

    Scenario: The Qtree exists but the configuration has been changed
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for NetAppQtree functional tests
        And a configuration hashtable with ensure = present for a NetApp Qtree
        When the NetAppQtree resources properties are updated
            | PropertyName  | PropertyValue |
            | Oplocks       | disabled      |
            | SecurityStyle | mixed         |
        And the NetAppQtree resources set method is executed
        Then diagnostics tests against the NetAppQtree should all pass
        And the NetAppQtree resource test method should respond true

    Scenario: The Qtree does exists and it is not supposed to
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for NetAppQtree functional tests
        And a configuration hashtable with ensure = absent for a NetApp Qtree
        When the NetAppQtree resources set method is executed
        Then diagnostics tests against the NetAppQtree should all pass
        And the NetAppQtree resource test method should respond true
