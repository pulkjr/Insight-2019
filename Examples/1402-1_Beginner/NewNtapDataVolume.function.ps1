function New-NtapDataVolume {
    param ($Controller, $Name, $Vserver, $Aggregate, $Size, $Protocol)

    if (-not (Get-NcVserver -Vserver $Vserver -Controller $controller)) {
        Write-Error -Message "Vserver not found: $Vserver"
        return
    }

    if (-not (Get-NcAggr -Name $Aggregate -Controller $controller -ErrorAction Ignore)) {
        Write-Error -Message "Aggregate not found: $Aggregate"
        return
    }

    if (Get-NcVol -Name $Name -Vserver $Vserver -Controller $controller) {
        Write-Error -Message "Volume exists: $Volume"
        return
    }

    $params = @{
        Name           = $Name
        VserverContext = $Vserver
        Aggregate      = $Aggregate
        JunctionPath   = "/$Name"
        Size           = $Size
    }

    switch -exact ($Protocol) {
        'CIFS' {
            $params.Add('SecurityStyle', 'ntfs')
            
            $outputVol = New-NcVol @params -Controller $Controller

            ## Add-NcCifsShare
            ## Enable-NcVscan

            $outputVol
        }
        'NFS' {
            $params.Add('SecurityStyle', 'unix')
            $params.Add('ExportPolicy', 'ExportPol1')

            $outputVol = New-NcVol @params -Controller $Controller

            $outputVol
        }
    }
}
