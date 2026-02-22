[CmdletBinding()]
param(
    [string]$BaseUrl = "https://agazoth.github.io",
    [string]$RubyBin = "C:\Ruby27-x64\bin",
    [switch]$SkipBundleOutdated,
    [switch]$SkipBuild,
    [switch]$FailOnOutdated
)

$ErrorActionPreference = 'Stop'
$hasFailures = $false

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Script
    )

    Write-Host "`n==> $Name" -ForegroundColor Cyan
    try {
        & $Script
        if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            throw "Command exited with code $LASTEXITCODE"
        }
        Write-Host "PASS: $Name" -ForegroundColor Green
    }
    catch {
        $script:hasFailures = $true
        Write-Host "FAIL: $Name" -ForegroundColor Red
        Write-Host $_ -ForegroundColor DarkRed
    }
}

function Get-StatusCode {
    param([string]$Url)

    try {
        $response = Invoke-WebRequest -Uri $Url -MaximumRedirection 5 -Method Get -ErrorAction Stop
        return [int]$response.StatusCode
    }
    catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            return [int]$_.Exception.Response.StatusCode
        }
        return -1
    }
}

if (Test-Path $RubyBin) {
    $env:Path = "$RubyBin;$env:Path"
}

Invoke-Step -Name "Ruby available" -Script {
    ruby --version
}

Invoke-Step -Name "Bundler available" -Script {
    bundle --version
}

if (-not $SkipBundleOutdated) {
    Write-Host "`n==> Bundle outdated check" -ForegroundColor Cyan
    $outdatedOutput = & bundle outdated --strict 2>&1
    $outdatedExit = $LASTEXITCODE

    if ($outdatedExit -eq 0) {
        Write-Host "PASS: No outdated gems in bundle" -ForegroundColor Green
    }
    elseif ($outdatedExit -eq 1) {
        if ($FailOnOutdated) {
            $hasFailures = $true
            Write-Host "FAIL: Outdated gems found" -ForegroundColor Red
        }
        else {
            Write-Host "WARN: Outdated gems found (non-fatal)" -ForegroundColor Yellow
        }
        $outdatedOutput | Write-Host
    }
    else {
        $hasFailures = $true
        Write-Host "FAIL: bundle outdated returned exit code $outdatedExit" -ForegroundColor Red
        $outdatedOutput | Write-Host
    }
}

if (-not $SkipBuild) {
    Invoke-Step -Name "Jekyll build" -Script {
        bundle exec jekyll build
    }
}

Write-Host "`n==> Production endpoint checks" -ForegroundColor Cyan
$checks = @(
    @{ Path = "/"; Expected = 200 },
    @{ Path = "/feed.xml"; Expected = 200 },
    @{ Path = "/ads.txt"; Expected = 200 },
    @{ Path = "/app-ads.txt"; Expected = 200 },
    @{ Path = "/README.html"; Expected = 404 },
    @{ Path = "/MAINTENANCE_PLAN.html"; Expected = 404 }
)

$results = foreach ($check in $checks) {
    $url = "$($BaseUrl.TrimEnd('/'))$($check.Path)"
    $actual = Get-StatusCode -Url $url
    $ok = $actual -eq $check.Expected
    if (-not $ok) { $hasFailures = $true }

    [pscustomobject]@{
        Url = $url
        Expected = $check.Expected
        Actual = $actual
        Result = if ($ok) { "PASS" } else { "FAIL" }
    }
}

$results | Format-Table -AutoSize

if ($hasFailures) {
    Write-Host "`nMonthly check completed with failures." -ForegroundColor Red
    exit 1
}

Write-Host "`nMonthly check completed successfully." -ForegroundColor Green
exit 0
