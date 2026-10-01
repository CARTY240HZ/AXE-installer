#Requires -Version 5.1
<#
.SYNOPSIS  Descarga la ultima release de AXE, verifica SHA256 y lanza el instalador.
.NOTES     No instala nada si el hash no coincide. Requiere que el repo sea accesible
           (publico; si es privado la descarga anonima falla).
#>
$ErrorActionPreference = 'Stop'
$repo = 'CARTY240HZ/AXE-installer'
$tmp  = Join-Path $env:TEMP ('AXE-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $tmp | Out-Null
try {
    $rel  = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'AXE-Get' }
    $zipA = $rel.assets | Where-Object name -like 'AXE-*.zip' | Select-Object -First 1
    $sumA = $rel.assets | Where-Object name -eq 'SHA256SUMS'  | Select-Object -First 1
    if (-not $zipA -or -not $sumA) { throw "La release $($rel.tag_name) no trae ZIP y SHA256SUMS." }
    $zip  = Join-Path $tmp $zipA.name
    $sums = Join-Path $tmp 'SHA256SUMS'
    Invoke-WebRequest $zipA.browser_download_url -OutFile $zip  -UseBasicParsing
    Invoke-WebRequest $sumA.browser_download_url -OutFile $sums -UseBasicParsing
    $line = Get-Content $sums | Where-Object { $_ -like "*$($zipA.name)*" } | Select-Object -First 1
    if (-not $line) { throw "SHA256SUMS no lista $($zipA.name)." }
    $esperado = $line.Split(' ')[0].ToLower()
    $real     = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
    if ($real -ne $esperado) { throw "HASH NO COINCIDE. Esperado $esperado, obtenido $real. No se instala." }
    Write-Host "SHA256 verificado: $real" -ForegroundColor Green
    $out = Join-Path $tmp 'pkg'
    Expand-Archive $zip $out
    $inst = Join-Path $out 'Install-AXE.ps1'
    Write-Host 'Lanzando instalador (pedira administrador)...' -ForegroundColor Cyan
    Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$inst`"", '-AllowUnsigned', '-Verify'
}
finally {
    if (Test-Path $tmp) { [IO.Directory]::Delete($tmp, $true) }
}
