#!/usr/bin/env pwsh
param([Parameter(Mandatory)] [String] $Version, [String] $ScpTarget)

$ProgressPreference = 'SilentlyContinue'

$_v = $Version -replace '\.'

# Download first all the files
@('', '-arm64', '-x64') | ForEach-Object {
    $url = "https://www.7-zip.org/a/7z${_v}${_}.exe"
    Write-Output "Downloading '$url'"
    Invoke-WebRequest $url -OutFile (Join-Path $PSScriptRoot (($url -split '/')[-1]))
}

# Download source code
Write-Host 'Downloading source code'
Invoke-WebRequest "https://www.7-zip.org/a/7z${_v}-src.tar.xz" -OutFile "$PSScriptRoot/7z${_v}-src.tar.xz"

Set-Content "$PSScriptRoot/README.md" @'
# 7-zip repacked as zip

Zero dependency zip package of 7-zip mainly for NanoServer installations and use for Shovel installer.

All archived were built by [script](https://github.com/shovel-org/Base/main/support/7zip/repack.ps1) using 7zip

Original site, source code and artifcats are avaialble at <https://www.7-zip.org>
'@ -Encoding 'utf8'

$7zPath = (Get-Command -Name '7z' -CommandType 'Application').Source

# Extract original 7-zips
Get-ChildItem -LiteralPath $PSScriptRoot -Include '*.exe' -File | ForEach-Object {
    $checksum = (Get-FileHash -LiteralPath $_.FullName -Algorithm 'SHA256').Hash

    Write-Output "Original '$($_.Name)' checksum: $checksum"

    & $7zPath x -y -o"$PSScriptRoot/$($_.BaseName)/" $_.FullName

    Remove-Item -LiteralPath $_.FullName -Force -Recurse
}

# Create new zips
Get-ChildItem -LiteralPath $PSScriptRoot -Directory | ForEach-Object {
    Write-Output "Repackaing '$($_.BaseName).zip'"

    & $7zPath a "$PSScriptRoot/$($_.BaseName).zip" $_.FullName

    $zipHash = (Get-FileHash -LiteralPath "$($_.FullName).zip" -Algorithm 'SHA256').Hash
    Write-Output "New '$($_.BaseName).zip' checksum: $zipHash"

    Remove-Item $_.Fullname -Force -Recurse
}

if ($ScpTarget) {
    Write-Output 'Copying all required files to server'
    scp "$PSScriptRoot/*" $ScpTarget

    # Remove all temporary files
    Get-ChildItem -LiteralPath $PSScriptRoot -Exclude '*.ps1' | Remove-Item -Force -Recurse
}
#!/usr/bin/env pwsh
param([Parameter(Mandatory)] [String] $Version, [String] $ScpTarget)

$ProgressPreference = 'SilentlyContinue'

$_v = $Version -replace '\.'

# Download first all the files
@('', '-arm64', '-x64') | ForEach-Object {
    $url = "https://www.7-zip.org/a/7z${_v}${_}.exe"
    Write-Output "Downloading '$url'"
    Invoke-WebRequest $url -OutFile (Join-Path $PSScriptRoot (($url -split '/')[-1]))
}

# Download source code
Write-Host 'Downloading source code'
Invoke-WebRequest "https://www.7-zip.org/a/7z${_v}-src.tar.xz" -OutFile "$PSScriptRoot/7z${_v}-src.tar.xz"

Set-Content "$PSScriptRoot/README.md" @'
# 7-zip repacked as zip

Zero dependency zip package of 7-zip mainly for NanoServer installations and use for Shovel installer.

All archived were built by [script](https://github.com/shovel-org/Base/main/support/7zip/repack.ps1) using 7zip

Original site, source code and artifcats are avaialble at <https://www.7-zip.org>
'@ -Encoding 'utf8'

$7zPath = (Get-Command -Name '7z' -CommandType 'Application').Source

# Extract original 7-zips
Get-ChildItem -LiteralPath $PSScriptRoot -Include '*.exe' -File | ForEach-Object {
    $checksum = (Get-FileHash -LiteralPath $_.FullName -Algorithm 'SHA256').Hash

    Write-Output "Original '$($_.Name)' checksum: $checksum"

    & $7zPath x -y -o"$PSScriptRoot/$($_.BaseName)/" $_.FullName

    Remove-Item -LiteralPath $_.FullName -Force -Recurse
}

# Create new zips
Get-ChildItem -LiteralPath $PSScriptRoot -Directory | ForEach-Object {
    Write-Output "Repackaing '$($_.BaseName).zip'"

    & $7zPath a "$PSScriptRoot/$($_.BaseName).zip" $_.FullName

    $zipHash = (Get-FileHash -LiteralPath "$($_.FullName).zip" -Algorithm 'SHA256').Hash
    Write-Output "New '$($_.BaseName).zip' checksum: $zipHash"

    Remove-Item $_.Fullname -Force -Recurse
}

if ($ScpTarget) {
    Write-Output 'Copying all required files to server'
    scp "$PSScriptRoot/*" $ScpTarget

    # Remove all temporary files
    Get-ChildItem -LiteralPath $PSScriptRoot -Exclude '*.ps1' | Remove-Item -Force -Recurse
}
#!/usr/bin/env pwsh
param([Parameter(Mandatory)] [String] $Version, [String] $ScpTarget)

$ProgressPreference = 'SilentlyContinue'

$_v = $Version -replace '\.'

# Download first all the files
@('', '-arm64', '-x64') | ForEach-Object {
    $url = "https://www.7-zip.org/a/7z${_v}${_}.exe"
    Write-Output "Downloading '$url'"
    Invoke-WebRequest $url -OutFile (Join-Path $PSScriptRoot (($url -split '/')[-1]))
}

# Download source code
Write-Host 'Downloading source code'
Invoke-WebRequest "https://www.7-zip.org/a/7z${_v}-src.tar.xz" -OutFile "$PSScriptRoot/7z${_v}-src.tar.xz"

Set-Content "$PSScriptRoot/README.md" @'
# 7-zip repacked as zip

Zero dependency zip package of 7-zip mainly for NanoServer installations and use for Shovel installer.

All archived were built by [script](https://github.com/shovel-org/Base/main/support/7zip/repack.ps1) using 7zip

Original site, source code and artifcats are avaialble at <https://www.7-zip.org>
'@ -Encoding 'utf8'

$7zPath = (Get-Command -Name '7z' -CommandType 'Application').Source

# Extract original 7-zips
Get-ChildItem -LiteralPath $PSScriptRoot -Include '*.exe' -File | ForEach-Object {
    $checksum = (Get-FileHash -LiteralPath $_.FullName -Algorithm 'SHA256').Hash

    Write-Output "Original '$($_.Name)' checksum: $checksum"

    & $7zPath x -y -o"$PSScriptRoot/$($_.BaseName)/" $_.FullName

    Remove-Item -LiteralPath $_.FullName -Force -Recurse
}

# Create new zips
Get-ChildItem -LiteralPath $PSScriptRoot -Directory | ForEach-Object {
    Write-Output "Repackaing '$($_.BaseName).zip'"

    & $7zPath a "$PSScriptRoot/$($_.BaseName).zip" $_.FullName

    $zipHash = (Get-FileHash -LiteralPath "$($_.FullName).zip" -Algorithm 'SHA256').Hash
    Write-Output "New '$($_.BaseName).zip' checksum: $zipHash"

    Remove-Item $_.Fullname -Force -Recurse
}

if ($ScpTarget) {
    Write-Output 'Copying all required files to server'
    scp "$PSScriptRoot/*" $ScpTarget

    # Remove all temporary files
    Get-ChildItem -LiteralPath $PSScriptRoot -Exclude '*.ps1' | Remove-Item -Force -Recurse
}
