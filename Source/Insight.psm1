try
{
    ( Test-ModuleManifest -Path "$( $MyInvocation.MyCommand.Path -replace '.psm1', '.psd1' )" -ErrorAction Ignore ).FileList | Where-Object { $_ -match '(?:Public|Private).+[.]ps1$' } | ForEach-Object { . $_ }
}
catch
{
    $Global:Error.RemoveAt(0)

    throw "One of the script files failed to load. Reason: $( $_.Exception.Message )"
}