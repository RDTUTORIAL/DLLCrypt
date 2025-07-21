param (
    [string]$encodedDllPath,
    [string]$password
)

try {
    $encodedDllBytes = [System.IO.File]::ReadAllBytes($encodedDllPath)

    $signature = [System.Text.Encoding]::UTF8.GetBytes("<!--ENDDLL-->")
    $sigLength = $signature.Length
    $found = $false

    for ($i = 0; $i -lt $encodedDllBytes.Length - $sigLength; $i++) {
        $subArray = New-Object byte[] $sigLength
        [Array]::Copy($encodedDllBytes, $i, $subArray, 0, $sigLength)
        $areEqual = $true
        for ($j = 0; $j -lt $sigLength; $j++) {
            if ($subArray[$j] -ne $signature[$j]) {
                $areEqual = $false
                break
            }
        }

        if ($areEqual) {
            $sigPos = $i
            $found = $true
            break
        }
    }

    if (-not $found) {        
        Write-Host "[!] error"
        exit
    }

    $lengthPos = $sigPos + $sigLength
    $encryptedDataLengthBytes = $encodedDllBytes[$lengthPos..($lengthPos+3)]
    $encryptedDataLength = [BitConverter]::ToUInt32($encryptedDataLengthBytes, 0)

    $encryptedDataPos = $lengthPos + 4
    $encryptedData = $encodedDllBytes[$encryptedDataPos..($encryptedDataPos + $encryptedDataLength - 1)]

    function Decrypt-Data {
        param (
            [byte[]]$encryptedData,
            [string]$password
        )

        $salt = $encryptedData[0..15]
        $iv = $encryptedData[16..31]
        $data = $encryptedData[32..($encryptedData.Length - 1)]

        $keyDerivation = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, 10000)
        $key = $keyDerivation.GetBytes(32)

        $aes = New-Object System.Security.Cryptography.AesManaged
        $aes.Key = $key
        $aes.IV = $iv

        $decryptor = $aes.CreateDecryptor()
        $ms = New-Object System.IO.MemoryStream
        $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $decryptor, 'Write')
        $cs.Write($data, 0, $data.Length)
        $cs.Close()
        $decryptedData = $ms.ToArray()
        $ms.Close()

        return $decryptedData
    }

    $decryptedData = Decrypt-Data -encryptedData $encryptedData -password $password

    $fileNameLength = [BitConverter]::ToUInt16($decryptedData[0..1], 0)
    $fileNameBytes = $decryptedData[2..(2 + $fileNameLength - 1)]
    $fileName = [System.Text.Encoding]::UTF8.GetString($fileNameBytes)
    $fileContent = $decryptedData[(2 + $fileNameLength)..($decryptedData.Length - 1)]

    $outputPath = Join-Path (Get-Location) $fileName
    [System.IO.File]::WriteAllBytes($outputPath, $fileContent)

} catch {
    Write-Host "[!] error"
}
