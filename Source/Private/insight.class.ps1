class InsightBase
{
    [string] $Name

    InsightBase () { }

    static [string] ConvertAsciiToHex ( [string]$asciiValue )
    {
        $hexValues = @()

        for ( $i = 1; $i -le $asciiValue.Length; $i++ )
        {
            $stringValue = $asciiValue.SubString( ( $i - 1 ), 1 )

            $hexValues += "{0:X}" -f [byte][char]$stringValue
        }
        
        return [string]::join( "", $hexValues ).ToLower();
    }
    [DataONTAP.C.Types.Volume.VolumeAttributes] GetVolume ( [string]$Name )
    {
        [DataONTAP.C.Types.Volume.VolumeAttributes] $_vol = Get-NcVol -Name $Name
        
        return $_vol
    }
}