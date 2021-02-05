$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name

if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Error "Processor not supported: $procName"
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $url = 'https://drivers.amd.com/drivers/amd_chipset_software_2.13.27.501.exe'
    $checksum = '9192ca6b5def85df0e70a6f72d35ffb6a51b9d4b7a98f538fb936ad9d699fc5b'
    $filePath = "$toolsDir\amd-chipset-drivers.exe"

    $downloadArgs = @{
        packageName  = $env:ChocolateyPackageName
        fileFullPath = $filePath
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

    Start-Process -FilePath "$filePath" -ArgumentList "/S" -Wait
    New-Item -Path "$filePath.ignore" -ItemType File -Force -ErrorAction SilentlyContinue
}
