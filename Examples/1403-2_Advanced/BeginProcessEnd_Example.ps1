function Function1 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [int[]]$InputObject
    )

    begin {
        Write-Host 'begin Function1'
    }
    process {
        Write-Host 'process Function1'

        foreach ($i in $InputObject) {
            Write-Host '--foreach Function1'
            Write-Output $i
        }
    }
    end {
        Write-Host 'end Function1'
    }
}

function Function2 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [int[]]$InputObject
    )

    begin {
        Write-Host 'begin Function2'
    }
    process {
        Write-Host 'process Function2'

        foreach ($i in $InputObject) {
            Write-Host '--foreach Function2'
            Write-Output $i
        }
    }
    end {
        Write-Host 'end Function2'
    }
}


function Function3 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [int[]]$InputObject
    )

    begin {
        Write-Host 'begin Function3'
    }
    process {
        Write-Host 'process Function3'

        foreach ($i in $InputObject) {
            Write-Host '--foreach Function3'
            Write-Output $i
        }
    }
    end {
        Write-Host 'end Function3'
    }
}

1..5 | Function1 | Function2 | Function3

#Function1 -InputObject @( 1,2,3,4,5 ) | Function2 | Function3
