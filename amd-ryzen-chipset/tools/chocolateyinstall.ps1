$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Error "Processor not supported: $procName"
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $url = 'https://drivers.amd.com/drivers/AMD_Chipset_Software_win10_2.17.25.506.exe'
    $checksum = '67ec549946f804d5d764ca042d2572465194bdcde453ca7ab80829445d1c7d0a'
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
