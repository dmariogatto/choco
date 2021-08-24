$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Warning 'Skipping uninstall...'
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $checksum = '8ccb49cd82d8ae4d421224b0bba3769b161603fd0bd6edec3cd9072c321424a7'
    $filePath = "$toolsDir\amd-chipset-drivers.exe"

    Get-ChecksumValid -File $filePath -Checksum $checksum -ChecksumType 'sha256'

    Start-Process -FilePath "$filePath" -ArgumentList "/S /EXPRESSUNINSTALL=1" -Wait

    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
    Remove-Item "$filePath.ignore" -Recurse -Force -ErrorAction SilentlyContinue
}
