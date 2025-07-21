param (
    [string]$dllPath,         
    [string]$secretFilePath,  
    [string]$password,      
    [string]$outputDllPath
)

$dllBytes = [System.IO.File]::ReadAllBytes($dllPath)
$secretBytes = [System.IO.File]::ReadAllBytes($secretFilePath)
$secretFileName = [System.IO.Path]::GetFileName($secretFilePath)
$secretFileNameBytes = [System.Text.Encoding]::UTF8.GetBytes($secretFileName)

$fileNameLength = $secretFileNameBytes.Length
if ($fileNameLength -gt 65535) {
    Write-Host "[!] error"
    exit
}
$dataToEncrypt = [BitConverter]::GetBytes([uint16]$fileNameLength) + $secretFileNameBytes + $secretBytes

function Encrypt-Data {
    param (
        [byte[]]$data,
        [string]$password
    )

    $salt = New-Object byte[] 16
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($salt)
    
    $keyDerivation = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, 10000)
    $key = $keyDerivation.GetBytes(32) 

    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = $key
    $aes.IV = New-Object byte[] 16
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($aes.IV)

    $encryptor = $aes.CreateEncryptor()
    $ms = New-Object System.IO.MemoryStream
    $cs = New-Object System.Security.Cryptography.CryptoStream($ms, $encryptor, 'Write')
    $cs.Write($data, 0, $data.Length)
    $cs.Close()
    $encryptedData = $ms.ToArray()
    $ms.Close()

    return $salt + $aes.IV + $encryptedData
}

$encryptedData = Encrypt-Data -data $dataToEncrypt -password $password

$signature = [System.Text.Encoding]::UTF8.GetBytes("<!--ENDDLL-->")

$encryptedDataLength = [BitConverter]::GetBytes([uint32]$encryptedData.Length)

$encodedDllBytes = $dllBytes + $signature + $encryptedDataLength + $encryptedData

[System.IO.File]::WriteAllBytes($outputDllPath, $encodedDllBytes)
