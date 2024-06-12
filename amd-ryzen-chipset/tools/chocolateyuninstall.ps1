$ErrorActionPreference = 'Stop';

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

    $checksum = 'aec3062bbcba01ddb5f1154b3fa8d7a79dd237c630c205f2e5a97fbcdfea5926'

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
