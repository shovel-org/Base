$urls = @()

$implemented = Get-ChildItem './bucket/' -File | Select-Object -ExpandProperty 'BaseName'
$excludes = @(
    'forego'
    'teleport'
    'ngrok'
    'dinun'
)

# Get all URLS
foreach ($f in Get-ChildItem '../Extras/bucket/', '../Main/bucket/', '../Ash258/bucket' -File | Where-Object -Property 'BaseName' -NotIn @($excludes + $implemented) ) {
    $json = Get-Content $f.FullName -Raw | ConvertFrom-Json

    if ($json.architecture.'arm64') { continue }

    if ($json.url) {
        Write-Host $f.BaseName -ForegroundColor 'Yellow'
        $urls += $json.url
    } elseif ($json.architecture) {
        Write-Host $f.BaseName -ForegroundColor 'Yellow'
        foreach ($b in '64bit', '32bit') {
            if ($json.architecture.$b.url) {
                $urls += $json.architecture.$b.url
            }
        }
    }
}

# Replace amd64 to known arm strings
$all64 = $urls | Where-Object { $_ -like '*amd64*' }
$arm = $all64 -replace 'amd64', 'arm64'
$aaa = $all64 -replace 'amd64', 'aarch64'
$all = @($arm + $aaa)
$valid = @()

# Test all urls
foreach ($a in $all) {
    $request = [System.Net.WebRequest]::Create($a) # TODO: Consider spliting #/ from URL to prevent potential faulty response
    $request.AllowAutoRedirect = $true
    $request.Headers.Add('Referer', ($a -split '/')[-1])
    $request.Headers.Add('User-Agent', 'Shovel/1.0 (+https://shovel.ash258.com) PowerShell/7.2 (Windows NT 10.0.22000.0; )')

    try {
        $response = $request.GetResponse()
        $response.Close()
    } catch {
        continue
    }

    $valid += $a
}

Write-Host ($valid -join "`r`n") -f 'green'
