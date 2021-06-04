$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Warning 'Skipping uninstall...'
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $checksum = '67ec549946f804d5d764ca042d2572465194bdcde453ca7ab80829445d1c7d0a'
    $filePath = "$toolsDir\amd-chipset-drivers.exe"

    Get-ChecksumValid -File $filePath -Checksum $checksum -ChecksumType 'sha256'

    Start-Process -FilePath "$filePath" -ArgumentList "/S /EXPRESSUNINSTALL=1" -Wait

    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
    Remove-Item "$filePath.ignore" -Recurse -Force -ErrorAction SilentlyContinue
}
