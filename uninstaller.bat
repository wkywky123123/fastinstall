@echo off
setlocal
title Clash for Windows Uninstaller

REM =================================================================================
REM                            Ӧ����Ϣ����
REM =================================================================================
set "APP_NAME=Clash for Windows"
set "EXECUTABLE_NAME=Clash for Windows.exe"
set "REG_UNINSTALL_KEY=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%APP_NAME%"
set "PROXY_REG_KEY=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
set "USER_DATA_PATH=%USERPROFILE%\.config\clash"
REM =================================================================================


REM (�˲��ִ����ޱ仯)
REM ...
REM ������ԱȨ��
net session >nul 2>&1
if "%errorLevel%" neq "0" ( echo. & echo �������Թ���Ա������д�ж�س��� & pause & exit /b )
echo Ȩ�޼��ͨ���� & echo.

REM ��̬��ȡ·����ȷ��
set "INSTALL_PATH=%~dp0"
set "SHORTCUT_PATH=%Public%\Desktop\%APP_NAME%.lnk"

echo ---------------------------------------------------------------------
echo            ^> ^> ^>  %APP_NAME% ж�س���  ^< ^< ^<
echo ---------------------------------------------------------------------
echo. & echo �˲����������ļ�����г���ɾ�� %APP_NAME%�� & echo.
echo ��Ҫɾ���İ�װĿ¼: & echo %INSTALL_PATH% & echo.
set /p "confirm=���棺�˲������ɻָ�����ȷ��Ҫ������ (y/n): "
if /i not "%confirm%"=="y" ( echo ��ȡ��ж�ء� & pause & exit /b )
echo.


REM 3. ��ʼִ��ж������
echo 1. ����ǿ�ƹر� %APP_NAME% ������ؽ���...
taskkill /f /im "%EXECUTABLE_NAME%" /t >nul 2>&1
echo    �����ѹرա�


echo.
echo 2. ��������ϵͳ����������ȷ��������������...
reg add "%PROXY_REG_KEY%" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
reg add "%PROXY_REG_KEY%" /v ProxyServer /t REG_SZ /d "" /f >nul
echo    ϵͳ�����ѹرա�


REM --- MODIFIED: ��3����ɾ�����п�ݷ�ʽ ---
echo.
echo 3. ����ɾ����ݷ�ʽ...

REM 3a. ɾ�������ݷ�ʽ
if exist "%SHORTCUT_PATH%" (
    del "%SHORTCUT_PATH%" & echo    - �����ݷ�ʽ��ɾ����
) else (
    echo    - δ�ҵ������ݷ�ʽ��
)

REM 3b. ɾ����ʼ�˵���ݷ�ʽ���ļ���
set "START_MENU_FOLDER=%ProgramData%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
if exist "%START_MENU_FOLDER%" (
    rmdir /s /q "%START_MENU_FOLDER%" & echo    - ��ʼ�˵���ݷ�ʽ��ɾ����
) else (
    echo    - δ�ҵ���ʼ�˵���ݷ�ʽ��
)


REM (�������ִ����ޱ仯)
REM ...
REM 4. ���ڴ�ע�����ɾ��ж����Ϣ...
echo. & echo 4. ���ڴ�ע�����ɾ��ж����Ϣ...
reg delete "%REG_UNINSTALL_KEY%" /f >nul 2>&1
if %errorlevel% equ 0 ( echo    ע�����Ϣ������) else ( echo    δ�ҵ�ע�����Ϣ������ʧ�ܡ�)

REM 5. ѯ���Ƿ�ɾ���û�����
echo. & echo ---------------------------------------------------------------------
echo                       ��ѡ�����û������ļ�
echo --------------------------------------------------------------------- & echo.
set /p "deleteChoice=�Ƿ�Ҫɾ�������û������ļ�(���ġ���¼��)��(y/n): "
if /i "%deleteChoice%"=="y" (
    echo. & echo    ���ڼ���û������ļ�Ŀ¼...
    if exist "%USER_DATA_PATH%" (
        echo        ����ɾ��: %USER_DATA_PATH%
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Remove-Item -Path '%USER_DATA_PATH%' -Recurse -Force -ErrorAction SilentlyContinue"
        echo        �û������ļ���ɾ����
    ) else (
        echo        δ�ҵ��û������ļ�Ŀ¼��������
    )
) else (
    echo. & echo    ��ѡ�����û������ļ���
)

REM 6. ׼��ɾ��Ӧ�ó����ļ�
echo. & echo --------------------------------------------------------------------- & echo.
echo 5. ׼��ɾ��Ӧ�ó����ļ�...
echo    ж�س�����3����Զ��رգ��������������

REM ����ɾ���߼�
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