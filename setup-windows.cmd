@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -File "%~dp0scripts\setup-windows.ps1" -Install
set "setup_result=%errorlevel%"
echo.
if not "%setup_result%"=="0" echo Setup stopped. Read the message above. Do not disable company security settings.
pause
exit /b %setup_result%
