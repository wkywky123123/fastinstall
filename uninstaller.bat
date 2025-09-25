@echo off
setlocal
title Clash for Windows Uninstaller

REM =================================================================================
REM                            应用信息配置
REM =================================================================================
set "APP_NAME=Clash for Windows"
set "EXECUTABLE_NAME=Clash for Windows.exe"
set "REG_UNINSTALL_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%APP_NAME%"
set "PROXY_REG_KEY=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
set "USER_DATA_PATH=%USERPROFILE%\.config\clash"
REM =================================================================================


REM (此部分代码无变化)
REM ...
REM 检查管理员权限
net session >nul 2>&1
if "%errorLevel%" neq "0" ( echo. & echo 错误：请以管理员身份运行此卸载程序。 & pause & exit /b )
echo 权限检查通过。 & echo.

REM 动态获取路径并确认
set "INSTALL_PATH=%~dp0"
set "SHORTCUT_PATH=%Public%\Desktop\%APP_NAME%.lnk"

echo ---------------------------------------------------------------------
echo            ^> ^> ^>  %APP_NAME% 卸载程序  ^< ^< ^<
echo ---------------------------------------------------------------------
echo. & echo 此操作将从您的计算机中彻底删除 %APP_NAME%。 & echo.
echo 将要删除的安装目录: & echo %INSTALL_PATH% & echo.
set /p "confirm=警告：此操作不可恢复。您确定要继续吗？ (y/n): "
if /i not "%confirm%"=="y" ( echo 已取消卸载。 & pause & exit /b )
echo.


REM 3. 开始执行卸载流程
echo 1. 正在强制关闭 %APP_NAME% 所有相关进程...
taskkill /f /im "%EXECUTABLE_NAME%" /t >nul 2>&1
echo    进程已关闭。


echo.
echo 2. 正在重置系统代理设置以确保网络连接正常...
reg add "%PROXY_REG_KEY%" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
reg add "%PROXY_REG_KEY%" /v ProxyServer /t REG_SZ /d "" /f >nul
echo    系统代理已关闭。


REM --- MODIFIED: 第3步，删除所有快捷方式 ---
echo.
echo 3. 正在删除快捷方式...

REM 3a. 删除桌面快捷方式
if exist "%SHORTCUT_PATH%" (
    del "%SHORTCUT_PATH%" & echo    - 桌面快捷方式已删除。
) else (
    echo    - 未找到桌面快捷方式。
)

REM 3b. 删除开始菜单快捷方式和文件夹
set "START_MENU_FOLDER=%ProgramData%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
if exist "%START_MENU_FOLDER%" (
    rmdir /s /q "%START_MENU_FOLDER%" & echo    - 开始菜单快捷方式已删除。
) else (
    echo    - 未找到开始菜单快捷方式。
)


REM (后续部分代码无变化)
REM ...
REM 4. 正在从注册表中删除卸载信息...
echo. & echo 4. 正在从注册表中删除卸载信息...
reg delete "%REG_UNINSTALL_KEY%" /f >nul 2>&1
if %errorlevel% equ 0 ( echo    注册表信息已清理。) else ( echo    未找到注册表信息或清理失败。)

REM 5. 询问是否删除用户数据
echo. & echo ---------------------------------------------------------------------
echo                       可选清理：用户配置文件
echo --------------------------------------------------------------------- & echo.
set /p "deleteChoice=是否要删除所有用户配置文件(订阅、记录等)？(y/n): "
if /i "%deleteChoice%"=="y" (
    echo. & echo    正在检查用户配置文件目录...
    if exist "%USER_DATA_PATH%" (
        echo        正在删除: %USER_DATA_PATH%
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Remove-Item -Path '%USER_DATA_PATH%' -Recurse -Force -ErrorAction SilentlyContinue"
        echo        用户配置文件已删除。
    ) else (
        echo        未找到用户配置文件目录，跳过。
    )
) else (
    echo. & echo    已选择保留用户配置文件。
)

REM 6. 准备删除应用程序文件
echo. & echo --------------------------------------------------------------------- & echo.
echo 5. 准备删除应用程序文件...
echo    卸载程序将在3秒后自动关闭，并完成最后的清理。

REM 最终删除逻辑
set "CLEAN_PATH=%INSTALL_PATH:~0,-1%"
cd /d "%TEMP%"
(
    echo @echo off
    echo timeout /t 3 /nobreak ^>nul
    echo powershell -NoProfile -ExecutionPolicy Bypass -Command "Remove-Item -Path \""%CLEAN_PATH%"\" -Recurse -Force -ErrorAction SilentlyContinue"
    echo del "%%~f0"
) > "%TEMP%\deleter.bat"
start "" /b "%TEMP%\deleter.bat"
exit