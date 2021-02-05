$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Warning 'Skipping uninstall...'
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $checksum = '9192ca6b5def85df0e70a6f72d35ffb6a51b9d4b7a98f538fb936ad9d699fc5b'
    $filePath = "$toolsDir\amd-chipset-drivers.exe"

    Get-ChecksumValid -File $filePath -Checksum $checksum -ChecksumType 'sha256'

    Start-Process -FilePath "$filePath" -ArgumentList "/S /EXPRESSUNINSTALL=1" -Wait

    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
    Remove-Item "$filePath.ignore" -Recurse -Force -ErrorAction SilentlyContinue
}
