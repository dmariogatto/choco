$ErrorActionPreference = 'Stop';

$procName = (Get-WmiObject Win32_Processor).Name
if (!$procName.Contains('Ryzen')) {
    Write-Warning 'Only compatible with AMD Ryzen processors!'
    Write-Error "Processor not supported: $procName"
}
else {
    $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $url = 'https://drivers.amd.com/drivers/amd_chipset_software_3.09.01.140.zip'
    $checksum = 'fc25b7c630c1eb803dd3ba8b9aa7ab9a19cc4e1703d92bf855c56d753f7143f4'    
    $zipPath = "$toolsDir\amd_chipset_drivers.zip"
    
    $downloadArgs = @{
        packageName  = $env:ChocolateyPackageName
        fileFullPath = $zipPath
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
    
    $unzipDir = "$toolsDir\amd_chipset_drivers"
    $installerFilePath = "$unzipDir\AMD_Chipset_Software.exe"

    Get-ChocolateyUnzip -FileFullPath $zipPath -Destination $unzipDir
    
    if (Test-Path $installerFilePath) {
        Start-Process -FilePath "$installerFilePath" -ArgumentList "/S" -Wait
        Remove-Item $unzipDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Error "Could not find chipset installer: $installerFilePath"
    }
}
