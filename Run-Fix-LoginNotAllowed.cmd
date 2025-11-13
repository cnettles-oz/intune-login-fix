@echo off
echo This will repair local logon rights so you can sign in with your
echo normal work account again.
echo.
echo You MUST run this as Administrator.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Fix-LoginNotAllowed.ps1"

echo.
echo All done. Please RESTART your computer now.
pause
