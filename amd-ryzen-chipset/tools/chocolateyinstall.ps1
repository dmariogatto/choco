$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name

if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Error "Processor not supported: $procName"
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $url = 'https://drivers.amd.com/drivers/amd_chipset_software_2.10.13.408.exe'
    $checksum = 'f53ab2b3d8d8e2c8f6a50ff2c921304125b9b8ee7eedd9db27dd4d1a56687db7'
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

    Start-Process -FilePath "$env:comspec" -ArgumentList "/c START /WAIT `"`" `"$filePath`" /S" -NoNewWindow -Wait
    New-Item -Path "$filePath.ignore" -ItemType File
}
