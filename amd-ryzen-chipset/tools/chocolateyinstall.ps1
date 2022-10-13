$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Error "Processor not supported: $procName"
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    $installerFileName = 'AMD_Chipset_Software.exe'
    $installerFilePath = "$toolsDir\$installerFileName"
    $unzipDir = "$toolsDir\amd_chipset_drivers"

    $url = 'https://drivers.amd.com/drivers/amd_chipset_software_4.09.23.507.exe'
    $checksum = '7df442d143e44e7304fb3c363e64db8824610a1f6f30cfd19796383034fb308d'

    $downloadFilePath = $installerFilePath

    $isZip = $url.EndsWith('.zip')
    if ($isZip) {
        $downloadFilePath = "$toolsDir\amd_chipset_drivers.zip"
    }

    $downloadArgs = @{
        packageName  = $env:ChocolateyPackageName
        fileFullPath = $downloadFilePath
        url          = $url
        checksum     = $checksum
        checksumType = 'sha256'
        options      = @{
            Headers = @{             
                Accept  = '*/*'
                Referer = 'https://www.amd.com/en/support/chipsets/amd-socket-am4/a320'
            }
        }
    }

    Get-ChocolateyWebFile @downloadArgs
        
    if ($isZip) {        
        Get-ChocolateyUnzip -FileFullPath $downloadFilePath -Destination $unzipDir
        $installerFilePath = "$unzipDir\$installerFileName"
    }
           
    if (Test-Path $installerFilePath) {
        Start-Process -FilePath "$installerFilePath" -ArgumentList "/S" -Wait
        New-Item -Path "$installerFilePath.ignore" -ItemType File -Force -ErrorAction SilentlyContinue
        Remove-Item $unzipDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        Remove-Item $unzipDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Error "Could not find chipset installer: $installerFilePath"        
    }
}
