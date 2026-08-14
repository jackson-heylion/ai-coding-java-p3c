param(
    [ValidateSet('auto','compile','test','static','verify','all','fast','p3c','full')]
    [string]$Mode = 'auto',
    [string]$ProjectDir = '.'
)

$ErrorActionPreference = 'Stop'
Set-Location $ProjectDir

if (-not (Test-Path 'pom.xml')) {
    throw "pom.xml not found in $(Get-Location)"
}

if (Test-Path '.\mvnw.cmd') {
    $Mvn = '.\mvnw.cmd'
} elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
    $Mvn = 'mvn'
} else {
    throw 'Maven not found; install Maven or add mvnw.cmd.'
}

function Invoke-Maven([string[]]$Arguments) {
    $base = @('-q')
    if ($env:MAVEN_THREADS) { $base += @('-T', $env:MAVEN_THREADS) }
    Write-Host "+ $Mvn $($base + $script:ScopeArgs + $Arguments -join ' ')"
    & $Mvn @base @script:ScopeArgs @Arguments
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Has-PmdProfile {
    return (Select-String -Path 'pom.xml' -Pattern '<id>\s*p3c-local\s*</id>' -Quiet)
}

function Require-PmdProfile {
    if (-not (Has-PmdProfile)) {
        throw "Missing Maven profile 'p3c-local' (see examples/maven/p3c-local-profile.xml)."
    }
}

$script:ScopeArgs = @()
function Set-Scope([string]$Modules = $env:MODULES) {
    $script:ScopeArgs = @()
    if ($Modules) { $script:ScopeArgs = @('-pl', $Modules, '-am') }
}

function Get-ChangedFiles {
    $files = @()
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $files += git diff --name-only --diff-filter=ACMRD HEAD -- 2>$null
        $files += git ls-files --others --exclude-standard 2>$null
    }
    return $files | Where-Object { $_ } | Sort-Object -Unique
}

function Test-ContextOnly([string[]]$Files) {
    foreach ($file in $Files) {
        if ($file -match '(^|/)(docs|\.ai|\.agents)/' -or $file -match '\.md$' -or $file -match '(^|/)README' -or $file -match '(^|/)LICENSE') { continue }
        return $false
    }
    return $true
}

function Find-Module([string]$File) {
    $dir = Split-Path $File -Parent
    while ($dir -and $dir -ne '.') {
        if (Test-Path (Join-Path $dir 'pom.xml')) { return ($dir -replace '\\','/') }
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return '.'
}

function Set-AutoScope {
    $files = @(Get-ChangedFiles)
    if ($files.Count -eq 0) {
        Write-Host 'INFO: no working-tree changes; nothing to validate.'
        return $false
    }
    if (Test-ContextOnly $files) {
        Write-Host 'INFO: only documentation/AI-rule files changed; Java build skipped.'
        return $false
    }

    $modules = @()
    foreach ($file in $files) {
        if ($file -match '^(pom\.xml|\.mvn/|mvnw|mvnw\.cmd|config/pmd/|scripts/verify-java\.(sh|ps1))') {
            Set-Scope ''
            return $true
        }
        $module = Find-Module $file
        if ($module -eq '.') {
            Set-Scope ''
            return $true
        }
        $modules += $module
    }

    $csv = ($modules | Sort-Object -Unique) -join ','
    if ($csv) {
        Write-Host "INFO: changed Maven modules: $csv"
        Set-Scope $csv
    } else {
        Set-Scope ''
    }
    return $true
}

function Run-Compile { Invoke-Maven @('-DskipTests','compile') }
function Run-Test {
    if ($env:TEST) {
        Invoke-Maven @("-Dtest=$($env:TEST)",'-Dsurefire.failIfNoSpecifiedTests=false','test')
    } else {
        Invoke-Maven @('test')
    }
}
function Run-Static { Require-PmdProfile; Invoke-Maven @('-Pp3c-local','-DskipTests','pmd:check') }
function Run-Verify { Invoke-Maven @('verify') }
function Run-All { Require-PmdProfile; Invoke-Maven @('-Pp3c-local','verify') }

switch ($Mode) {
    'fast'   { $Mode = 'test' }
    'p3c'    { $Mode = 'static' }
    'full'   { $Mode = 'verify' }
}

switch ($Mode) {
    'compile' { Set-Scope; Run-Compile }
    'test'    { Set-Scope; Run-Test }
    'static'  { Set-Scope; Run-Static }
    'verify'  { Set-Scope; Run-Verify }
    'all'     { Set-Scope; Run-All }
    'auto' {
        if (Set-AutoScope) {
            if (Has-PmdProfile) { Run-All }
            else {
                Write-Host 'INFO: p3c-local not configured; running scoped Maven verify only.'
                Run-Verify
            }
        }
    }
}
