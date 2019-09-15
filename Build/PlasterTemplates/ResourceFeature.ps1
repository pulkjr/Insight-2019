<%
@"
Feature: Manage Lifecycle of ${PLASTER_PARAM_ResourceName}

    Scenario: The Cifs Share does not exist and one is desired
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for ${PLASTER_PARAM_ResourceName} functional tests
        And ${PLASTER_PARAM_ResourceName} is missing
        And a configuration hashtable with ensure = present for a ${PLASTER_PARAM_ResourceName}
        When the ${PLASTER_PARAM_ResourceName} resources set method is executed
        Then diagnostics tests against the ${PLASTER_PARAM_ResourceName} should all pass
        And the ${PLASTER_PARAM_ResourceName} resource test method should respond true

    Scenario: The Cifs Share exists but the configuration has been changed
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for ${PLASTER_PARAM_ResourceName} functional tests
        And a configuration hashtable with ensure = present for a ${PLASTER_PARAM_ResourceName}
        When the ${PLASTER_PARAM_ResourceName} resources properties are updated
            | PropertyName      | PropertyValue          |
        And the ${PLASTER_PARAM_ResourceName} resources set method is executed
        Then diagnostics tests against the ${PLASTER_PARAM_ResourceName} should all pass
        And the ${PLASTER_PARAM_ResourceName} resource test method should respond true

    Scenario: The Cifs Share does exists and it is not supposed to
        Given a Windows Server with required PowerShell modules loaded
        And the test environment is configured for ${PLASTER_PARAM_ResourceName} functional tests
        And a configuration hashtable with ensure = absent for a NetApp Cifs Share
        When the ${PLASTER_PARAM_ResourceName} resources set method is executed
        Then diagnostics tests against the ${PLASTER_PARAM_ResourceName} should all pass
        And the ${PLASTER_PARAM_ResourceName} resource test method should respond true
"@
%>
