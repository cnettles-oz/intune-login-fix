@echo off
echo.
echo === Fixing Windows sign-in so 'Other user' is visible ===
echo.

REM Enable fast user switching
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v HideFastUserSwitching /t REG_DWORD /d 0 /f

REM Make sure last logged-on user is allowed to show
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v DontDisplayLastUserName /t REG_DWORD /d 0 /f

REM Same setting in Winlogon (some baselines use this key)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" ^
 /v DontDisplayLastUserName /t REG_DWORD /d 0 /f

REM Require Ctrl+Alt+Del (helps force proper sign-in UI)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" ^
 /v DisableCAD /t REG_DWORD /d 0 /f

echo.
echo Done. Please sign out or restart the PC and check the sign-in screen.
echo You should now see 'Other user' so you can log in with your normal account.
echo.
pause
