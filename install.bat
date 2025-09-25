@echo off
setlocal enabledelayedexpansion
title Clash For Windows Installer

REM =================================================================================
REM                            脚本和应用配置区域
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


REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 ( echo 请以管理员身份运行此脚本。 & pause & exit /b )
set "TEMP_ZIP_PATH=%TEMP%\ClashForWindows.zip"
set "TEMP_PATCH_PATH=%TEMP%\app.asar"
set "DOWNLOADER_SCRIPT=%~dp0downloader.ps1"
if not exist "%DOWNLOADER_SCRIPT%" ( echo 未找到下载器。 & pause & exit /b )

:SelectInstallType
cls
echo =====================================================================
echo                 %APP_NAME% 安装程序
echo =====================================================================
echo. & echo  请选择安装类型: & echo.
echo    [1] 默认安装 (推荐) & echo    [2] 自定义安装 & echo.
set /p choice="请输入您的选择 (1 或 2): "
if "%choice%"=="1" goto DefaultInstall
if "%choice%"=="2" goto CustomInstall
echo. & echo  无效的输入！ & timeout /t 2 >nul & goto SelectInstallType

:DefaultInstall
echo. & echo 默认安装
set "INSTALL_PATH=%ProgramFiles%\%APP_NAME%"
goto MainInstallLogic

:CustomInstall
echo. & echo 即将打开文件夹选择窗口...
set "USER_SELECTED_PATH="
for /f "tokens=* delims=" %%i in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $folder = New-Object System.Windows.Forms.FolderBrowserDialog; $folder.Description = '请选择 %APP_NAME% 的安装位置'; $folder.ShowDialog() | Out-Null; Write-Output $folder.SelectedPath"') do ( set "USER_SELECTED_PATH=%%i" )

if not defined USER_SELECTED_PATH ( echo 取消安装 & pause & exit /b )

set "INSTALL_PATH=!USER_SELECTED_PATH!\%APP_NAME%"
goto MainInstallLogic

REM 安装流程
:MainInstallLogic
echo. & echo 程序将安装到: %INSTALL_PATH% & echo. & pause

REM 下载和解压
echo 正在准备下载 %APP_NAME%...
powershell -ExecutionPolicy Bypass -File "%DOWNLOADER_SCRIPT%" -SourceURL "%MAIN_DOWNLOAD_URL%" -DestinationPath "%TEMP_ZIP_PATH%"

if not exist "%TEMP_ZIP_PATH%" (
    echo 下载失败，请检查您的网络连接或联系开发者确认下载链接是否有效
    pause
    exit /b
)
echo 正在展开文件...
if not exist "%INSTALL_PATH%" ( mkdir "%INSTALL_PATH%" )
powershell -Command "Expand-Archive -Path '%TEMP%\ClashForWindows.zip' -DestinationPath '%INSTALL_PATH%\' -Force"
echo 解压缩完成

    
REM 4. 创建快捷方式
echo.
echo 正在创建快捷方式...
set "EXECUTABLE_PATH=%INSTALL_PATH%\%EXECUTABLE_NAME%"
set "SHORTCUT_PATH=%Public%\Desktop\%APP_NAME%.lnk"
powershell -Command "$Shell = New-Object -ComObject WScript.Shell; $Shortcut = $Shell.CreateShortcut('%SHORTCUT_PATH%'); $Shortcut.TargetPath = '%EXECUTABLE_PATH%'; $Shortcut.WorkingDirectory = '%INSTALL_PATH%'; $Shortcut.IconLocation = '%EXECUTABLE_PATH%'; $Shortcut.Save()"
echo    - 桌面快捷方式创建成功！
set "START_MENU_FOLDER=%ProgramData%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
set "START_MENU_SHORTCUT_PATH=%START_MENU_FOLDER%\%APP_NAME%.lnk"
if not exist "%START_MENU_FOLDER%" mkdir "%START_MENU_FOLDER%"
powershell -Command "$Shell = New-Object -ComObject WScript.Shell; $Shortcut = $Shell.CreateShortcut('%START_MENU_SHORTCUT_PATH%'); $Shortcut.TargetPath = '%EXECUTABLE_PATH%'; $Shortcut.WorkingDirectory = '%INSTALL_PATH%'; $Shortcut.IconLocation = '%EXECUTABLE_PATH%'; $Shortcut.Save()"
echo    - 开始菜单快捷方式创建成功！

REM 5. 写入注册表信息
echo. & echo 正在注册应用程序信息...
set "UNINSTALLER_PATH=%INSTALL_PATH%\uninstaller.exe"
reg add "%REG_UNINSTALL_KEY%" /v DisplayName /t REG_SZ /d "%APP_NAME%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v DisplayVersion /t REG_SZ /d "%APP_VERSION%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v Publisher /t REG_SZ /d "%APP_PUBLISHER%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v InstallLocation /t REG_SZ /d "%INSTALL_PATH%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v DisplayIcon /t REG_SZ /d "%EXECUTABLE_PATH%" /f >nul
reg add "%REG_UNINSTALL_KEY%" /v UninstallString /t REG_SZ /d "\"%UNINSTALLER_PATH%\"" /f >nul
echo 软件注册信息写入成功！

REM 6. 清理临时文件
echo. & echo 正在清理临时文件... & if exist "%TEMP%\ClashForWindows.zip" ( del "%TEMP%\ClashForWindows.zip" ) & echo 清理完成！

REM 7. 汉化破解
echo. & set /p choice="是否应用汉化补丁？ (y/n): "
if /i not "%choice%"=="y" ( goto EndInstall )
echo. & echo ================================================================
echo               即将下载并应用汉化补丁...
echo ================================================================ & timeout /t 5
powershell -ExecutionPolicy Bypass -File "%DOWNLOADER_SCRIPT%" -SourceURL "%PATCH_DOWNLOAD_URL%" -DestinationPath "%TEMP_PATCH_PATH%"
if not exist "%TEMP_PATCH_PATH%" ( echo 下载汉化补丁失败... & pause & exit /b )
echo 补丁下载完成。 & echo 正在应用补丁...
move /Y "%TEMP_PATCH_PATH%" "%INSTALL_PATH%\resources\"
if exist "%INSTALL_PATH%\resources\app.asar" ( echo 汉化成功！ ) else ( echo 汉化失败。)

:EndInstall
echo. & echo 所有操作已完成！
start "" "%FINAL_WEBSITE_URL%"
endlocal
pause```