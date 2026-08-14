param(
    [ValidateSet('17','21','all')]
    [string]$Mode = 'all'
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Pom = Join-Path $Root 'examples\compatibility\pom.xml'

if (Test-Path (Join-Path $Root 'mvnw.cmd')) {
    $Mvn = Join-Path $Root 'mvnw.cmd'
} elseif (Get-Command mvn -ErrorAction SilentlyContinue) {
    $Mvn = 'mvn'
} else {
    throw 'Maven not found.'
}

function Get-JavaMajor {
    $output = & java -XshowSettings:properties -version 2>&1
    $line = $output | Select-String 'java.specification.version\s*=' | Select-Object -First 1
    if (-not $line) { return $null }
    $value = (($line.Line -split '=', 2)[1]).Trim()
    if ($value.StartsWith('1.')) { $value = $value.Substring(2) }
    return [int]$value
}

function Require-Java21 {
    $major = Get-JavaMajor
    if (-not $major -or $major -lt 21) {
        throw "Java 21+ is required for Java 21 syntax smoke tests. Current runtime: $major"
    }
}

function Invoke-Maven([string[]]$Arguments) {
    Write-Host "+ $Mvn $($Arguments -join ' ')"
    & $Mvn @Arguments
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

switch ($Mode) {
    '17' { Invoke-Maven @('-q','-f',$Pom,'-pl','java17','-am','verify') }
    '21' { Require-Java21; Invoke-Maven @('-q','-f',$Pom,'-pl','java21','-am','verify') }
    'all' { Require-Java21; Invoke-Maven @('-q','-f',$Pom,'verify') }
}
