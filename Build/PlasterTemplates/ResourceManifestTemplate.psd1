<%
@"
@{
    ModuleVersion        = '0.0.1'
    GUID                 = '${PLASTER_Guid1}'
    Author               = '${PLASTER_PARAM_Author}'
    CompanyName          = 'NetApp'
    Copyright            = '(c) ${PLASTER_Year} NetApp Corporation. All rights reserved.'
    Description          = '${PLASTER_PARAM_ResourceDescription}'
    RootModule           = '${PLASTER_PARAM_ResourceName}.psm1'
    DscResourcesToExport = '${PLASTER_PARAM_ResourceName}'
    RequiredModules      = 'DataONTAP'
}
"@
%>
