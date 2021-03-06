$urls = @()

$implemented = Get-ChildItem './bucket/' -File | Select-Object -ExpandProperty 'BaseName'
$excludes = @(
    'forego'
    'teleport'
    'ngrok'
    'rust-msvc'
    'rust-msvc-nightly'
    'rust-nightly'
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
$all64 += $urls | Where-Object { $_ -like '*x86_64*' }
$all64 += $urls | Where-Object { $_ -like '*x64*' }
$all64 = $all64 | Select-Object -Unique

$arm = $all64 -replace 'amd64', 'arm64'
$arch = $all64 -replace 'amd64', 'aarch64'
$xarm = $all64 -replace 'x64', 'arm64'
$xarch = $all64 -replace 'x64', 'aarch64'
$x64arm = $all64 -replace 'x86_64', 'arm64'
$x64arch = $all64 -replace 'x86_64', 'aarch64'

$all = @($arm + $arch + $xarm + $xarch + $x64arm + $x64arch)
$all = $all | Where-Object { $_ -notlike '*amd64*' } | Where-Object { $_ -notlike '*x86_64*' } | Where-Object { $_ -notlike '*x64*' }
$valid = @()

# Test all urls
$i = 0
foreach ($a in $all) {
    ++$i
    Write-Progress -Id 1 -Activity "Processing '$a'" -PercentComplete ((100 / $all.Count) * $i)

    $request = [System.Net.WebRequest]::Create($a) # TODO: Consider spliting #/ from URL to prevent potential faulty response
    $request.AllowAutoRedirect = $true
    $ua = 'Shovel/1.0 (+https://shovel.ash258.com) PowerShell/7.2 (Windows NT 10.0.22000.0; )'
    $split = ($a -split '/')[-1]
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $request.Referer = $split
        $request.UserAgent = $ua
    } else {
        $request.Headers.Add('Referer', $split)
        $request.Headers.Add('User-Agent', $ua)
    }

    try {
        $response = $request.GetResponse()
        $response.Close()
    } catch {
        continue
    }

    Write-Verbose "Hit: $a"
    $valid += $a
}

Write-Host ($valid -join "`r`n") -f 'green'
