<%
@"
Given 'the test environment is configured for ${PLASTER_PARAM_ResourceName} functional tests' {
    `$ncController.Address | Should -Be `$ClusterIP
}
Given '${PLASTER_PARAM_ResourceName} is missing' {
    `$resource = Get-Nc -Controller $ncController #TODO: Correct validation of resource availability

    if ( `$resource )
    {
        #TODO: write removal script
    }
}
Given 'a configuration hashtable with ensure = (?<Ensure>\S+) for a ${PLASTER_PARAM_ResourceName}' {
    param ( `$Ensure )

    `$resourceProperties = @{
        Controller             = `$ClusterIP
        Credential             = `$ncCredentials
        Ensure                 = `$Ensure
    } #TODO: Add the properties to be executed on
}
"@
%>
