$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Warning 'Skipping uninstall...'
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $checksum = '8ccb49cd82d8ae4d421224b0bba3769b161603fd0bd6edec3cd9072c321424a7'
    $zipPath = "$toolsDir\amd_chipset_drivers.zip"

    Get-ChecksumValid -File $zipPath -Checksum $checksum -ChecksumType 'sha256'

    $unzipDir = "$toolsDir\amd_chipset_drivers"
    $installerFilePath = "$unzipDir\AMD_Chipset_Software.exe"

    Get-ChocolateyUnzip -FileFullPath $zipPath -Destination $unzipDir
    
    if (Test-Path $installerFilePath) {
        Start-Process -FilePath "$installerFilePath" -ArgumentList "/S /EXPRESSUNINSTALL=1" -Wait
        Remove-Item $unzipDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Error "Could not find chipset installer: $installerFilePath"
    }
}
