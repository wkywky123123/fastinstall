@echo off
setlocal enabledelayedexpansion
title Clash For Windows Installer

REM =================================================================================
REM                            �ű���Ӧ����������
REM =================================================================================
set "MAIN_DOWNLOAD_URL=https://download.mrgeda.top/clash/Clash For Windows.zip"
set "PATCH_DOWNLOAD_URL=https://download.mrgeda.top/clash/app.asar"
set "FINAL_WEBSITE_URL=https://help.mrgeda.top"
set "APP_NAME=Clash for Windows"
set "APP_VERSION=0.20.39"
set "APP_PUBLISHER=Clash Dev Team"
set "EXECUTABLE_NAME=Clash for Windows.exe"
set "REG_UNINSTALL_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%APP_NAME%"
REM =================================================================================


REM ������ԱȨ��
net session >nul 2>&1
if %errorLevel% neq 0 ( echo ���Թ���Ա������д˽ű��� & pause & exit /b )
set "TEMP_ZIP_PATH=%TEMP%\ClashForWindows.zip"
set "TEMP_PATCH_PATH=%TEMP%\app.asar"
set "DOWNLOADER_SCRIPT=%~dp0downloader.ps1"
if not exist "%DOWNLOADER_SCRIPT%" ( echo δ�ҵ��������� & pause & exit /b )

:SelectInstallType
cls
echo =====================================================================
echo                 %APP_NAME% ��װ����
echo =====================================================================
echo. & echo  ��ѡ��װ����: & echo.
echo    [1] Ĭ�ϰ�װ (�Ƽ�) & echo    [2] �Զ��尲װ & echo.
set /p choice="����������ѡ�� (1 �� 2): "
if "%choice%"=="1" goto DefaultInstall
if "%choice%"=="2" goto CustomInstall
echo. & echo  ��Ч�����룡 & timeout /t 2 >nul & goto SelectInstallType

:DefaultInstall
echo. & echo Ĭ�ϰ�װ
set "INSTALL_PATH=%ProgramFiles%\%APP_NAME%"
goto MainInstallLogic

:CustomInstall
echo. & echo �������ļ���ѡ�񴰿�...
set "USER_SELECTED_PATH="
for /f "tokens=* delims=" %%i in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.Description = '��ѡ�� %APP_NAME% �İ�װλ��'; $folder.ShowDialog() | Out-Null; Write-Output $folder.SelectedPath"') do ( set "USER_SELECTED_PATH=%%i" )

if not defined USER_SELECTED_PATH ( echo ȡ����װ & pause & exit /b )

set "INSTALL_PATH=!USER_SELECTED_PATH!\%APP_NAME%"
goto MainInstallLogic

REM ��װ����
:MainInstallLogic
echo. & echo ���򽫰�װ��: %INSTALL_PATH% & echo. & pause

REM ���غͽ�ѹ
echo ����׼������ %APP_NAME%...
powershell -ExecutionPolicy Bypass -File "%DOWNLOADER_SCRIPT%" -SourceURL "%MAIN_DOWNLOAD_URL%" -DestinationPath "%TEMP_ZIP_PATH%"

if not exist "%TEMP_ZIP_PATH%" (
    echo ����ʧ�ܣ����������������ӻ���ϵ������ȷ�����������Ƿ���Ч
    pause
    exit /b
)
echo ����չ���ļ�...
if not exist "%INSTALL_PATH%" ( mkdir "%INSTALL_PATH%" )
powershell -Command "Expand-Archive -Path '%TEMP%\ClashForWindows.zip' -DestinationPath '%INSTALL_PATH%\' -Force"
echo ��ѹ�����

    
REM 4. ������ݷ�ʽ
echo.
echo ���ڴ�����ݷ�ʽ...
set "EXECUTABLE_PATH=%INSTALL_PATH%\%EXECUTABLE_NAME%"
set "SHORTCUT_PATH=%Public%\Desktop\%APP_NAME%.lnk"
powershell -Command "$Shell = New-Object -ComObject WScript.Shell; $Shortcut = $Shell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%EXECUTABLE_PATH%'; $Shortcut.WorkingDirectory = '%INSTALL_PATH%'; $Shortcut.IconLocation = '%EXECUTABLE_PATH%'; $Shortcut.Save()"
echo    - �����ݷ�ʽ�����ɹ���
set "START_MENU_FOLDER=%ProgramData%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
set "START_MENU_SHORTCUT_PATH=%START_MENU_FOLDER%\%APP_NAME%.lnk"
if not exist "%START_MENU_FOLDER%" mkdir "%START_MENU_FOLDER%"
powershell -Command "$Shell = New-Object -ComObject WScript.Shell; $Shortcut = $Shell.CreateShortcut('%START_MENU_SHORTCUT_PATH%'); $Shortcut.TargetPath = '%EXECUTABLE_PATH%'; $Shortcut.WorkingDirectory = '%INSTALL_PATH%'; $Shortcut.IconLocation = '%EXECUTABLE_PATH%'; $Shortcut.Save()"
echo    - ��ʼ�˵���ݷ�ʽ�����ɹ���

REM 5. д��ע�����Ϣ
echo. & echo ����ע��Ӧ�ó�����Ϣ...
set "UNINSTALLER_PATH=%INSTALL_PATH%\uninstaller.exe"
reg add "%REG_UNINSTALL_KEY%" /v DisplayName /t REG_SZ /d "%APP_NAME%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v DisplayVersion /t REG_SZ /d "%APP_VERSION%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v Publisher /t REG_SZ /d "%APP_PUBLISHER%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v InstallLocation /t REG_SZ /d "%INSTALL_PATH%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v DisplayIcon /t REG_SZ /d "%EXECUTABLE_PATH%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v UninstallString /t REG_SZ /d "\"%UNINSTALLER_PATH%\"" /f >nul
echo ���ע����Ϣд��ɹ���

REM 6. ������ʱ�ļ�
echo. & echo ����������ʱ�ļ�... & if exist "%TEMP%\ClashForWindows.zip" ( del "%TEMP%\ClashForWindows.zip" ) & echo ������ɣ�

REM 7. �����ƽ�
echo. & set /p choice="�Ƿ�Ӧ�ú��������� (y/n): "
if /i not "%choice%"=="y" ( goto EndInstall )
echo. & echo ================================================================
echo               �������ز�Ӧ�ú�������...
echo ================================================================ & timeout /t 5
powershell -ExecutionPolicy Bypass -File "%DOWNLOADER_SCRIPT%" -SourceURL "%PATCH_DOWNLOAD_URL%" -DestinationPath "%TEMP_PATCH_PATH%"
if not exist "%TEMP_PATCH_PATH%" ( echo ���غ�������ʧ��... & pause & exit /b )
echo ����������ɡ� & echo ����Ӧ�ò���...
move /Y "%TEMP_PATCH_PATH%" "%INSTALL_PATH%\resources\"
if exist "%INSTALL_PATH%\resources\app.asar" ( echo �����ɹ��� ) else ( echo ����ʧ�ܡ�)

:EndInstall
echo. & echo ���в�������ɣ�
start "" "%FINAL_WEBSITE_URL%"
endlocal
pause```