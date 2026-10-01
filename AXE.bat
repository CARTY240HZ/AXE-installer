@echo off
setlocal
:: =====================================================
:: Launcher AXE - Elite Windows Optimizer
:: Modo GUI (sin argumentos): NO se eleva de entrada (issue #5 / auditoria 2026-09-22 s1.2).
:: WebView2 corre sin admin; el broker (src/46-broker.ps1, -Broker/-Token) eleva EL SOLO, bajo
:: demanda, solo cuando hace falta un tweak.apply/revert/masterRevert o un punto de restauracion.
:: Modos headless (CLI, con argumentos): se elevan como siempre, SALVO los que ni leen estado privilegiado ni modifican
:: nada (AXE-004: menos superficie elevada): -SelfTest, -GameList, -NetMon, -Mouse, -Dpc, -NetLoad y -Update -Check.
:: -List/-Export/-Diag/-Advice/-Benchmark SI se elevan: el estado de varios tweaks (BCD, mitigaciones) solo se lee con
:: admin, y sin el aparecerian como "off" aunque esten aplicados (y -Export escribiria un perfil falso).
::   AXE.bat -SelfTest   -> validacion de integridad del catalogo        (sin admin)
::   AXE.bat -List       -> estado real de cada tweak                     (admin)
::   AXE.bat -Export fichero.json                                          (admin)
::   AXE.bat -Import fichero.json   (requiere admin: se eleva)
::
:: ExecutionPolicy RemoteSigned: permite scripts locales y conserva Mark-of-the-Web.
:: AXE no desbloquea recursivamente binarios o scripts aportados por terceros.
:: =====================================================

set "AXE_PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "AXE_ENGINE=%~dp0dist\AXE.ps1"
if exist "%~dp0AXE.ps1" set "AXE_ENGINE=%~dp0AXE.ps1"

if "%~1"=="" goto :gui

:: --- Modos CLI: elevacion con reenvio de argumentos, solo si el modo la necesita. ---
set "AXE_RO="
set "AXE_UPD="
set "AXE_CHK="
set "AXE_MUT="
for %%A in (%*) do (
    for %%F in (-SelfTest -GameList -NetMon -Mouse -Dpc -NetLoad) do if /i "%%~A"=="%%F" set "AXE_RO=1"
    for %%F in (-Import -ImportExtreme -OptimizeGame -RevertGame -Session -Fps -List -Export -Diag -Advice -Benchmark -Measure -Score -Report -TimerSweep) do if /i "%%~A"=="%%F" set "AXE_MUT=1"
    if /i "%%~A"=="-Update" set "AXE_UPD=1"
    if /i "%%~A"=="-Check" set "AXE_CHK=1"
)
:: -Update -Check solo consulta: sin admin. -Update a secas reemplaza ficheros: admin.
if defined AXE_UPD if defined AXE_CHK if not defined AXE_MUT set "AXE_RO=1"
if defined AXE_UPD if not defined AXE_CHK set "AXE_MUT=1"
:: Se salta la elevacion SOLO si hay un modo puro y ninguno que lea/modifique estado privilegiado.
if defined AXE_RO if not defined AXE_MUT goto :run_cli
:: Se fijan FUERA del bloque: un ")" en un argumento (p. ej. "Program Files (x86)") cerraria el bloque en el parseo.
set "AXE_LAUNCHER=%~f0"
set "AXE_FORWARD_ARGS=%*"
net session >nul 2>&1
if %errorlevel% neq 0 (
    "%AXE_PS%" -NoProfile -Command "Start-Process -FilePath $env:AXE_LAUNCHER -ArgumentList $env:AXE_FORWARD_ARGS -Verb RunAs"
    exit /b
)
:run_cli
"%AXE_PS%" -NoProfile -ExecutionPolicy RemoteSigned -STA -File "%AXE_ENGINE%" %*
exit /b

:gui
:: --- Modo GUI: sin elevar. El broker eleva bajo demanda, por operacion. ---
"%AXE_PS%" -NoProfile -ExecutionPolicy RemoteSigned -STA -File "%AXE_ENGINE%"
exit /b
