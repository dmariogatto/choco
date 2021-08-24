$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Error "Processor not supported: $procName"
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $url = 'https://drivers.amd.com/drivers/amd_chipset_software_win10_3.08.17.735.zip'
    $checksum = '8ccb49cd82d8ae4d421224b0bba3769b161603fd0bd6edec3cd9072c321424a7'
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
