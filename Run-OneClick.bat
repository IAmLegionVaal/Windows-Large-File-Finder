@echo off
setlocal
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Find-WindowsLargeFiles.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo Windows Large File Finder finished with exit code %RC%.
pause
exit /b %RC%
