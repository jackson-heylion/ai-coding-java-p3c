param(
    [ValidateSet('new','existing')]
    [string]$Mode = 'existing',
    [string]$Target = '.',
    [switch]$Force,
    [switch]$PatchPom
)

$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (-not (Test-Path $Target)) { New-Item -ItemType Directory -Path $Target | Out-Null }
$Target = (Resolve-Path $Target).Path

if ($Mode -eq 'existing' -and -not (Test-Path (Join-Path $Target 'pom.xml'))) {
    throw "existing mode requires $Target\pom.xml"
}

function Install-File([string]$RelativePath) {
    $src = Join-Path $Root $RelativePath
    $dst = Join-Path $Target $RelativePath
    $parent = Split-Path $dst -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    if ((Test-Path $dst) -and -not $Force) {
        Write-Host "SKIP: $RelativePath already exists"
        return
    }

    Copy-Item $src $dst -Force
    Write-Host "ADD:  $RelativePath"
}

function Install-Tree([string]$RelativePath) {
    $base = Join-Path $Root $RelativePath
    Get-ChildItem $base -File -Recurse | Sort-Object FullName | ForEach-Object {
        $rel = $_.FullName.Substring($Root.Length + 1)
        Install-File $rel
    }
}

Install-File 'AGENTS.md'
Install-Tree '.ai'
Install-Tree '.agents'
Install-File 'config/pmd/p3c.xml'
Install-File 'scripts/verify-java.sh'
Install-File 'scripts/verify-java.ps1'
Install-File 'scripts/verify-java.cmd'

function Add-PmdProfile {
    $pom = Join-Path $Target 'pom.xml'
    if (-not (Test-Path $pom)) { throw '-PatchPom requires pom.xml' }

    $content = Get-Content $pom -Raw
    if ($content -match '<id>\s*p3c-local\s*</id>') {
        Write-Host 'INFO: p3c-local already exists in pom.xml'
        return
    }

    Copy-Item $pom "$pom.ai-p3c.bak" -Force
    $fragment = Get-Content (Join-Path $Root 'examples/maven/p3c-local-profile.xml') -Raw

    if ($content -match '</profiles>') {
        $content = [regex]::Replace($content, '</profiles>', "$fragment`r`n</profiles>", 1)
    } elseif ($content -match '</project>') {
        $block = "    <profiles>`r`n$fragment`r`n    </profiles>`r`n</project>"
        $content = [regex]::Replace($content, '</project>', $block, 1)
    } else {
        throw 'Cannot patch pom.xml: closing </project> tag not found.'
    }

    Set-Content -Path $pom -Value $content -Encoding UTF8
    Write-Host 'PATCH: pom.xml (backup: pom.xml.ai-p3c.bak)'
}

if ($PatchPom) { Add-PmdProfile }

Write-Host "`nInstalled into: $Target"
Write-Host "Mode: $Mode"
Write-Host "`nNext:"
Write-Host '  Windows:     scripts\verify-java.cmd auto'
Write-Host '  PowerShell:  powershell -File scripts\verify-java.ps1 auto'
Write-Host '  macOS/Linux: bash scripts/verify-java.sh auto'

$pomPath = Join-Path $Target 'pom.xml'
if ((Test-Path $pomPath) -and -not (Select-String -Path $pomPath -Pattern '<id>\s*p3c-local\s*</id>' -Quiet)) {
    Write-Host "`nStatic analysis is not enabled yet. Rerun with -PatchPom or merge examples/maven/p3c-local-profile.xml manually."
}
