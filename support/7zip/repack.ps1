#!/usr/bin/env pwsh
# ScpTarget should be in format user@host:/path/to/root/web/server/without/7zip/subfolder/and/without/trailing/slash
param([Parameter(Mandatory)] [String] $Version, [String] $ScpTarget)

$ProgressPreference = 'SilentlyContinue'

Start-Transcript "$PSScriptRoot/log.txt"

$_v = $Version -replace '\.'

# Download first all the files
@('', '-arm64', '-x64') | ForEach-Object {
    $url = "https://www.7-zip.org/a/7z${_v}${_}.exe"
    Write-Output "Downloading '$url'"
    Invoke-WebRequest $url -OutFile (Join-Path $PSScriptRoot (($url -split '/')[-1]))
}

# Download source code
Write-Host 'Downloading source code'
$scTar = "$PSScriptRoot/7z${_v}-src.tar.xz"
Invoke-WebRequest "https://www.7-zip.org/a/7z${_v}-src.tar.xz" -OutFile $scTar
$sourceHash = (Get-FileHash -LiteralPath $scTar -Algorithm 'SHA256').Hash

Set-Content "$PSScriptRoot/README.md" @'
# 7-zip repacked as zip

Zero dependency zip package of 7-zip mainly for NanoServer installations and use for Shovel installer.

All archives were built by [script](https://github.com/shovel-org/Base/main/support/7zip/repack.ps1) using 7zip.

Original site, source code and artifacts are available at <https://www.7-zip.org>
'@ -Encoding 'utf8'

$7zPath = (Get-Command -Name '7z' -CommandType 'Application')[0].Source

# Extract original 7-zips
Get-ChildItem -LiteralPath $PSScriptRoot -Include '*.exe' -File | ForEach-Object {
    $checksum = (Get-FileHash -LiteralPath $_.FullName -Algorithm 'SHA256').Hash

    Write-Output "Original '$($_.Name)' checksum: $checksum"

    & $7zPath x -y -o"$PSScriptRoot/$($_.BaseName)/" $_.FullName

    Remove-Item -LiteralPath $_.FullName -Force -Recurse
}

$checksums = @()
# Create new zips
Get-ChildItem -LiteralPath $PSScriptRoot -Directory | ForEach-Object {
    Write-Output "Repacking '$($_.BaseName).zip'"

    # Add source code to final zip
    Copy-Item "$PSScriptRoot/7z${_v}-src.tar.xz" $_.FullName
    & $7zPath a "$PSScriptRoot/$($_.BaseName).zip" $_.FullName

    $zipHash = (Get-FileHash -LiteralPath "$($_.FullName).zip" -Algorithm 'SHA256').Hash
    $zipName = "$($_.BaseName).zip"
    Write-Output "New '$zipName' checksum: $zipHash"
    $checksums += "$zipHash  $zipName"

    Remove-Item $_.Fullname -Force -Recurse
}
$checksums += "$sourceHash  7z${_v}-src.tar.xz"
Set-Content "$PSScriptRoot/${_v}_checksums.txt" $checksums

if ($ScpTarget) {
    Write-Output 'Copying all required files to server'
    Stop-Transcript

    Copy-Item "$PSScriptRoot/log.txt" "$PSScriptRoot/log-$_v.txt"
    scp -r "$PSScriptRoot/" "$ScpTarget/"

    # Remove all temporary files
    Get-ChildItem -LiteralPath $PSScriptRoot -Exclude '*.ps1', '*.txt', 'README.md' | Remove-Item -Force -Recurse
}
