﻿$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Warning 'Skipping uninstall...'
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    $installerFileName = 'AMD_Chipset_Software.exe'
    $installerFilePath = "$toolsDir\$installerFileName"
    $unzipDir = "$toolsDir\amd_chipset_drivers"

    $checksum = 'fdcbece1e12de9cc1b4972d8c455f6fe84c08a8907f21ab885712d2819089199'

    $downloadFilePath = $installerFilePath
    if (!(Test-Path $downloadFilePath)) {
        $downloadFilePath="$toolsDir\amd_chipset_drivers.zip"
    }
    if (!(Test-Path $downloadFilePath)) {
        Write-Error "Could not find downloaded chipset driver: $downloadFilePath"
    }

    Get-ChecksumValid -File $downloadFilePath -Checksum $checksum -ChecksumType 'sha256'

    $isZip = $downloadFilePath.EndsWith('.zip')
    if ($isZip) {        
        Get-ChocolateyUnzip -FileFullPath $downloadFilePath -Destination $unzipDir
        $installerFilePath = "$unzipDir\$installerFileName"
    }

    if (Test-Path $installerFilePath) {
        Start-Process -FilePath "$installerFilePath" -ArgumentList "/S /EXPRESSUNINSTALL=1" -Wait
        Remove-Item "$installerFilePath.ignore" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $unzipDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        Remove-Item $unzipDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Error "Could not find chipset installer: $installerFilePath"        
    }
}
