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

    $url = 'https://drivers.amd.com/drivers/amd_chipset_software_6.02.07.2300.exe'
    $checksum = 'adeef4821ef8f34e64ea93f6b836f7c0ba6d33b6000323c8894667a24b9add07'

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
