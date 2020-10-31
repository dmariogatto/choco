#!/bin/bash

set -e

MONTHS=(ZERO January February March April May June July August September October November December)

baseDir=$1
installScript="$baseDir/tools/chocolateyinstall.ps1"
nuspec="$baseDir/amd-ryzen-chipset.nuspec"

currentUrl=$(grep '$url =' $installScript | cut -d \' -f 2)
currentVersion=$(echo $currentUrl | sed 's/.*software_\(.*\).exe.*/\1/')
currentChecksum=$(grep '$checksum =' $installScript | cut -d \' -f 2)

echo "Current Url: $currentUrl"
echo "Current Version: $currentVersion"
echo "Current Checksum: $currentChecksum"

request=$(curl -s 'https://www.amd.com/en/support/chipsets/amd-socket-am4/b450' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0')

newUrl=$(echo $request | grep -m 1 -Eo 'https://drivers.amd.com/drivers/amd_chipset_software[^\"]+' | head -1)
newReleaseDate=$(echo $request | grep -oP '<time(?:\s[^>]*)?>\K.*?(?=</time>)' | head -1)
newVersion=$(echo $newUrl | sed 's/.*software_\(.*\).exe.*/\1/')

if [ -z "$newUrl" ]; then
    echo "Failed to get new download Url"
    exit 1
fi

if [ -z "$newReleaseDate" ]; then
    echo "Failed to get new release date"
    exit 1
fi

if [ -z "$newVersion" ]; then
    echo "Failed to get new version"
    exit 1
fi

IFS='/\' read month day year <<< $newReleaseDate
newReleaseDate="$year.$month.$day"

echo "New Url: $newUrl"
echo "New Release Date: $newReleaseDate"
echo "New Version: $newVersion"

if [ "$currentUrl" = "$newUrl" ]; then
    echo "Version is current, exiting..."
    exit    
fi

echo "Version update required"
echo "Downloading $newUrl"

fileName="$baseDir/amd-chipset-drivers.exe"
curl $newUrl -o $fileName -H 'Referer: https://www.amd.com/en/support/chipsets/amd-socket-am4/b450'

newChecksum=($(sha256sum $fileName))

echo "Old Checksum: $currentChecksum"
echo "New Checksum: $newChecksum"

echo "Updating $installScript"
sed -i "s#$currentUrl#$newUrl#g" $installScript
sed -i "s#$currentChecksum#$newChecksum#g" $installScript

echo "Updating $nuspec"
sed -r -i "s#<version>(.*?)</version>#<version>$newReleaseDate</version>#g" $nuspec
sed -i "s#^Revision Number:.*#Revision Number: **$newVersion**#g" $nuspec
sed -i "s#^Release Date:.*#Release Date: $day ${MONTHS[$month]} $year#g" $nuspec

rm $fileName
