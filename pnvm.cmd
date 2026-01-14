@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM pnvm - per-project Node.js version manager (Windows)
REM Version: v2.0.0
REM Per-project Node Version Manager (like nvm, but per-project)
REM ============================================================

REM Detect script name
set "SCRIPT_NAME=%~nx0"
set "TOOL_NAME=%SCRIPT_NAME:.cmd=%"

REM Resolve project root (folder where this script lives)
set "PROJECT_ROOT=%~dp0"
for %%I in ("%PROJECT_ROOT%") do set "PROJECT_ROOT=%%~fI"

if "%~1"=="" goto :usage

if /I "%~1"=="help" goto :usage
if /I "%~1"=="--help" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="init"     goto :init
if /I "%~1"=="use"      goto :use
if /I "%~1"=="list"     goto :list
if /I "%~1"=="current"  goto :current
if /I "%~1"=="remove"   goto :remove
if /I "%~1"=="alias"    goto :alias
if /I "%~1"=="unalias"  goto :unalias
if /I "%~1"=="aliases"  goto :aliases

REM For all other commands, ensure runtime exists
goto :run


:usage
echo.
echo %TOOL_NAME% - per-project Node.js environment
echo ----------------------------------------
echo Usage:
echo   %TOOL_NAME% init [version]        Initialize .pnenv for this project
echo   %TOOL_NAME% use ^<version^>         Switch to an installed Node version
echo   %TOOL_NAME% list                  Show installed Node versions
echo   %TOOL_NAME% current               Show active Node version
echo   %TOOL_NAME% remove ^<version^>     Remove a specific Node version
echo   %TOOL_NAME% alias ^<name^> ^<cmd^>  Create a command alias
echo   %TOOL_NAME% unalias ^<name^>       Remove an alias
echo   %TOOL_NAME% aliases               List all aliases
echo   %TOOL_NAME% node --version        Use project-local Node
echo   %TOOL_NAME% npm install           Use project-local npm
echo   %TOOL_NAME% dev                   Run "npm run dev"
echo   %TOOL_NAME% build                 Run "npm run build"
echo.
if "%~1"=="" exit /b 1
exit /b 0


REM Detect architecture
:detect_arch
set "ARCH=x64"
for /f "tokens=*" %%A in ('powershell -NoProfile -Command "if ([Environment]::Is64BitOperatingSystem) { Write-Output 'x64' } else { Write-Output 'x86' }"') do set "ARCH=%%A"
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
goto :eof


REM Parse package.json for engines.node
:detect_version_from_package_json
set "PKG_JSON=%PROJECT_ROOT%\package.json"
if not exist "%PKG_JSON%" exit /b 1

REM Use PowerShell to parse JSON
for /f "tokens=*" %%V in ('powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$json = Get-Content '%PKG_JSON%' | ConvertFrom-Json; ^
   if ($json.engines -and $json.engines.node) { ^
     $version = $json.engines.node -replace '[^0-9.]', ''; ^
     if ($version -match '^\d+\.\d+\.\d+') { Write-Output $matches[0] } ^
   }"') do (
    set "DETECTED_VERSION=%%V"
    exit /b 0
)
exit /b 1


REM Check shared cache
:check_shared_cache
set "VERSION_TO_CHECK=%~1"
set "SHARED_CACHE_DIR=%USERPROFILE%\.pnenv\cache"
set "CACHE_FILE=%SHARED_CACHE_DIR%\node-v%VERSION_TO_CHECK%-win-%ARCH%.zip"
if exist "%CACHE_FILE%" (
    set "SHARED_CACHE_FOUND=%CACHE_FILE%"
    exit /b 0
)
exit /b 1


:init
echo.
echo %TOOL_NAME%: initializing Node runtime inside this project...
echo Project: %PROJECT_ROOT%
echo.

call :detect_arch

set "DEFAULT_VERSION=20.0.0"
set "pnenv_VERSION=%~2"

REM Auto-detect from package.json if no version provided
if "%pnenv_VERSION%"=="" (
    call :detect_version_from_package_json
    if defined DETECTED_VERSION (
        echo %TOOL_NAME%: detected Node version from package.json: !DETECTED_VERSION!
        set /p CONFIRM="Use this version? (Y/n): "
        if /I "!CONFIRM!"=="n" (
            set "DETECTED_VERSION="
        ) else (
            set "pnenv_VERSION=!DETECTED_VERSION!"
        )
    )
)

if "%pnenv_VERSION%"=="" (
    set /p "pnenv_VERSION=Which Node.js version do you want? (default: %DEFAULT_VERSION%): "
)

if "%pnenv_VERSION%"=="" set "pnenv_VERSION=%DEFAULT_VERSION%"

REM Trim whitespace
for /f "tokens=* delims= " %%v in ("%pnenv_VERSION%") do set "pnenv_VERSION=%%v"

set "pnenv_DIR=%PROJECT_ROOT%\.pnenv"
set "CACHE_DIR=%pnenv_DIR%\cache"
set "SHARED_CACHE_DIR=%USERPROFILE%\.pnenv\cache"
set "RUNTIME_DIR=%pnenv_DIR%\node-v%pnenv_VERSION%-win-%ARCH%"
set "ZIP_PATH=%CACHE_DIR%\node-v%pnenv_VERSION%-win-%ARCH%.zip"
set "NODE_URL=https://nodejs.org/dist/v%pnenv_VERSION%/node-v%pnenv_VERSION%-win-%ARCH%.zip"

if not exist "%pnenv_DIR%" mkdir "%pnenv_DIR%"
if not exist "%CACHE_DIR%" mkdir "%CACHE_DIR%"

if exist "%RUNTIME_DIR%\node.exe" (
    echo %TOOL_NAME%: Node %pnenv_VERSION% already installed.
    goto :writeVersion
)

REM Check shared cache first
call :check_shared_cache %pnenv_VERSION%
if defined SHARED_CACHE_FOUND (
    echo %TOOL_NAME%: found Node %pnenv_VERSION% in shared cache, copying...
    if not exist "%SHARED_CACHE_DIR%" mkdir "%SHARED_CACHE_DIR%"
    copy "%SHARED_CACHE_FOUND%" "%ZIP_PATH%" >nul
    goto :extract
)

echo %TOOL_NAME%: downloading Node %pnenv_VERSION% ...
echo   URL: %NODE_URL%
echo.

REM Download with retry logic
set "RETRIES=3"
set "RETRY=0"
:download_retry
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$url    = '%NODE_URL%';" ^
  "$zip    = '%ZIP_PATH%';" ^
  "$target = '%pnenv_DIR%';" ^
  "try {" ^
  "  New-Item -ItemType Directory -Force -Path (Split-Path $zip) | Out-Null;" ^
  "  Write-Host 'Downloading Node...';" ^
  "  Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing;" ^
  "  Write-Host 'Download complete.'" ^
  "} catch {" ^
  "  Write-Host 'Download failed: ' $_.Exception.Message;" ^
  "  exit 1" ^
  "}"

if errorlevel 1 (
    set /a RETRY+=1
    if !RETRY! lss %RETRIES% (
        echo %TOOL_NAME%: download failed, retrying (!RETRY!/%RETRIES%)...
        timeout /t 2 /nobreak >nul
        goto :download_retry
    ) else (
        echo.
        echo %TOOL_NAME% ERROR: Failed to download Node after %RETRIES% attempts.
        exit /b 1
    )
)

REM Copy to shared cache if possible
if not exist "%SHARED_CACHE_DIR%" mkdir "%SHARED_CACHE_DIR%" 2>nul
if exist "%SHARED_CACHE_DIR%" copy "%ZIP_PATH%" "%SHARED_CACHE_DIR%\" >nul 2>&1

:extract
echo %TOOL_NAME%: extracting...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$zip    = '%ZIP_PATH%';" ^
  "$target = '%RUNTIME_DIR%';" ^
  "$tempDir = '%pnenv_DIR%\temp_extract';" ^
  "try {" ^
  "  New-Item -ItemType Directory -Force -Path $target | Out-Null;" ^
  "  Expand-Archive -Path $zip -DestinationPath $tempDir -Force;" ^
  "  $extracted = Get-ChildItem -Path $tempDir -Filter 'node.exe' -Recurse | Select-Object -First 1;" ^
  "  if ($extracted) {" ^
  "    $nodeDir = $extracted.Directory.FullName;" ^
  "    Copy-Item -Path \"$nodeDir\*\" -Destination $target -Recurse -Force;" ^
  "  } else {" ^
  "    Write-Host 'ERROR: node.exe not found in archive';" ^
  "    exit 1" ^
  "  }" ^
  "  Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "  Write-Host 'Extraction complete.'" ^
  "} catch {" ^
  "  Write-Host 'Extraction failed: ' $_.Exception.Message;" ^
  "  Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue;" ^
  "  exit 1" ^
  "}"

if errorlevel 1 (
    echo.
    echo %TOOL_NAME% ERROR: Failed to extract Node.
    exit /b 1
)

:writeVersion
> "%PROJECT_ROOT%\.pnenv-version" echo %pnenv_VERSION%

REM --- Ensure ignore files exist and include pnenv ---
if not exist "%PROJECT_ROOT%\.gitignore" (
    > "%PROJECT_ROOT%\.gitignore" echo # Ignore local Node runtimes
)
findstr /C:".pnenv/" "%PROJECT_ROOT%\.gitignore" >nul || echo .pnenv/>>"%PROJECT_ROOT%\.gitignore"
findstr /C:".pnenv-version" "%PROJECT_ROOT%\.gitignore" >nul || echo .pnenv-version>>"%PROJECT_ROOT%\.gitignore"
findstr /C:".pnenv-aliases" "%PROJECT_ROOT%\.gitignore" >nul || echo .pnenv-aliases>>"%PROJECT_ROOT%\.gitignore"

if not exist "%PROJECT_ROOT%\.svnignore" (
    > "%PROJECT_ROOT%\.svnignore" echo # Ignore local Node runtimes
)
findstr /C:".pnenv/" "%PROJECT_ROOT%\.svnignore" >nul || echo .pnenv/>>"%PROJECT_ROOT%\.svnignore"
findstr /C:".pnenv-version" "%PROJECT_ROOT%\.svnignore" >nul || echo .pnenv-version>>"%PROJECT_ROOT%\.svnignore"
findstr /C:".pnenv-aliases" "%PROJECT_ROOT%\.svnignore" >nul || echo .pnenv-aliases>>"%PROJECT_ROOT%\.svnignore"

echo.
echo %TOOL_NAME%: Installed Node %pnenv_VERSION% inside:
echo   %RUNTIME_DIR%
echo.
echo Try:
echo   %TOOL_NAME% use %pnenv_VERSION%
echo   %TOOL_NAME% node --version
echo.
exit /b 0


:use
if "%~2"=="" (
    echo Usage: %TOOL_NAME% use ^<version^> [--no-install]
    exit /b 1
)

call :detect_arch

set "pnenv_VERSION=%~2"
set "NO_INSTALL=%~3"
set "RUNTIME_DIR=%PROJECT_ROOT%\.pnenv\node-v%pnenv_VERSION%-win-%ARCH%"

if not exist "%RUNTIME_DIR%\node.exe" (
    echo %TOOL_NAME% ERROR: Node %pnenv_VERSION% is not installed.
    echo Run: %TOOL_NAME% init and specify that version first.
    exit /b 1
)

> "%PROJECT_ROOT%\.pnenv-version" echo %pnenv_VERSION%
echo %TOOL_NAME%: switched to Node %pnenv_VERSION%

REM Auto npm install
if not "%NO_INSTALL%"=="--no-install" (
    if exist "%PROJECT_ROOT%\package.json" (
        set "NODE_MODULES=%PROJECT_ROOT%\node_modules"
        if not exist "!NODE_MODULES!" (
            echo %TOOL_NAME%: running npm install...
            call "%RUNTIME_DIR%\npm.cmd" install
        ) else (
            REM Check if package.json is newer than node_modules
            for %%F in ("%PROJECT_ROOT%\package.json") do set "PKG_TIME=%%~tF"
            for %%F in ("%PROJECT_ROOT%\node_modules") do set "NODE_MODULES_TIME=%%~tF"
            if "%PKG_TIME%" gtr "%NODE_MODULES_TIME%" (
                echo %TOOL_NAME%: package.json is newer, running npm install...
                call "%RUNTIME_DIR%\npm.cmd" install
            )
        )
    )
)

exit /b 0


:list
call :detect_arch
echo Installed Node versions in this project:
set "CURRENT_VERSION="
if exist "%PROJECT_ROOT%\.pnenv-version" (
    set /p CURRENT_VERSION=<"%PROJECT_ROOT%\.pnenv-version"
)

for /d %%D in ("%PROJECT_ROOT%\.pnenv\node-v*") do (
    set "VER=%%~nD"
    set "VER=!VER:node-v=!"
    set "VER=!VER:-win-%ARCH%=!"
    if exist "%%D\node.exe" (
        if defined CURRENT_VERSION (
            if /I "!VER!"=="!CURRENT_VERSION!" (
                echo * !VER!
            ) else (
                echo   !VER!
            )
        ) else (
            echo   !VER!
        )
    )
)
exit /b 0


:current
set "pnenv_VERSION="
if exist "%PROJECT_ROOT%\.pnenv-version" (
    set /p pnenv_VERSION=<"%PROJECT_ROOT%\.pnenv-version"
)

if defined pnenv_VERSION (
    echo Current Node version: %pnenv_VERSION%
) else (
    echo %TOOL_NAME%: no active version. Run %TOOL_NAME% init or use.
    exit /b 1
)
exit /b 0


:remove
if "%~2"=="" (
    echo Usage: %TOOL_NAME% remove ^<version^>
    exit /b 1
)

call :detect_arch

set "REMOVE_VERSION=%~2"
set "REMOVE_DIR=%PROJECT_ROOT%\.pnenv\node-v%REMOVE_VERSION%-win-%ARCH%"

if not exist "%REMOVE_DIR%\node.exe" (
    echo %TOOL_NAME% ERROR: Node %REMOVE_VERSION% is not installed.
    exit /b 1
)

echo %TOOL_NAME%: removing Node %REMOVE_VERSION% ...
rmdir /s /q "%REMOVE_DIR%"

REM If current version matches removed, clear .pnenv-version
if exist "%PROJECT_ROOT%\.pnenv-version" (
    set /p CURR=<"%PROJECT_ROOT%\.pnenv-version"
    if /I "%CURR%"=="%REMOVE_VERSION%" (
        del "%PROJECT_ROOT%\.pnenv-version"
        echo %TOOL_NAME%: removed active version. Please run %TOOL_NAME% use or init again.
    )
)

echo %TOOL_NAME%: Node %REMOVE_VERSION% removed.
exit /b 0


:alias
if "%~2"=="" (
    echo Usage: %TOOL_NAME% alias ^<name^> ^<command^>
    exit /b 1
)

set "ALIAS_NAME=%~2"
set "ALIAS_CMD=%~3"
set "ALIASES_FILE=%PROJECT_ROOT%\.pnenv-aliases"

REM Remove existing alias if present
if exist "%ALIASES_FILE%" (
    findstr /V /C:"%ALIAS_NAME%=" "%ALIASES_FILE%" > "%ALIASES_FILE%.tmp" 2>nul
    move /Y "%ALIASES_FILE%.tmp" "%ALIASES_FILE%" >nul 2>&1
)

REM Add new alias
echo %ALIAS_NAME%=%ALIAS_CMD%>>"%ALIASES_FILE%"
echo %TOOL_NAME%: alias '%ALIAS_NAME%' created
exit /b 0


:unalias
if "%~2"=="" (
    echo Usage: %TOOL_NAME% unalias ^<name^>
    exit /b 1
)

set "ALIAS_NAME=%~2"
set "ALIASES_FILE=%PROJECT_ROOT%\.pnenv-aliases"

if not exist "%ALIASES_FILE%" (
    echo %TOOL_NAME%: no aliases defined.
    exit /b 1
)

findstr /C:"%ALIAS_NAME%=" "%ALIASES_FILE%" >nul
if errorlevel 1 (
    echo %TOOL_NAME% ERROR: alias '%ALIAS_NAME%' not found.
    exit /b 1
)

findstr /V /C:"%ALIAS_NAME%=" "%ALIASES_FILE%" > "%ALIASES_FILE%.tmp"
move /Y "%ALIASES_FILE%.tmp" "%ALIASES_FILE%" >nul
echo %TOOL_NAME%: alias '%ALIAS_NAME%' removed
exit /b 0


:aliases
set "ALIASES_FILE=%PROJECT_ROOT%\.pnenv-aliases"

if not exist "%ALIASES_FILE%" (
    echo No aliases defined.
    exit /b 0
)

echo Defined aliases:
for /f "tokens=1* delims==" %%A in ('type "%ALIASES_FILE%"') do (
    echo   %%A -^> %%B
)
exit /b 0


:get_alias
set "ALIAS_NAME=%~1"
set "ALIASES_FILE=%PROJECT_ROOT%\.pnenv-aliases"
set "ALIAS_CMD="

if exist "%ALIASES_FILE%" (
    for /f "tokens=1* delims==" %%A in ('findstr /C:"%ALIAS_NAME%=" "%ALIASES_FILE%"') do (
        set "ALIAS_CMD=%%B"
    )
)
goto :eof


:run
REM Load version from .pnenv-version
set "pnenv_VERSION="
if exist "%PROJECT_ROOT%\.pnenv-version" (
    set /p pnenv_VERSION=<"%PROJECT_ROOT%\.pnenv-version"
) else (
    echo %TOOL_NAME% ERROR: No .pnenv-version file found.
    echo Run:
    echo   %TOOL_NAME% init
    echo first.
    exit /b 1
)

call :detect_arch

set "pnenv_DIR=%PROJECT_ROOT%\.pnenv"
set "RUNTIME_DIR=%pnenv_DIR%\node-v%pnenv_VERSION%-win-%ARCH%"
set "NODE_EXE=%RUNTIME_DIR%\node.exe"
set "NPM_CMD=%RUNTIME_DIR%\npm.cmd"

if not exist "%NODE_EXE%" (
    echo %TOOL_NAME% ERROR: Node runtime missing:
    echo   %NODE_EXE%
    echo Run:
    echo   %TOOL_NAME% init
    exit /b 1
)

REM Put pnenv runtime at front of PATH
set "PATH=%RUNTIME_DIR%;%PATH%"

echo %TOOL_NAME%: using Node %pnenv_VERSION% from:
echo   %NODE_EXE%
echo -------------------------------------

set "FIRST_ARG=%~1"

REM Check for alias first
call :get_alias %FIRST_ARG%
if defined ALIAS_CMD (
    %ALIAS_CMD% %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM ------------------------------------------------------------
REM Case 1: Direct call: pnvm node ...
REM ------------------------------------------------------------
if /I "%FIRST_ARG%"=="node" (
    "%NODE_EXE%" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM ------------------------------------------------------------
REM Case 2: Direct call: pnvm npm ...
REM ------------------------------------------------------------
if /I "%FIRST_ARG%"=="npm" (
    "%NPM_CMD%" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM ------------------------------------------------------------
REM Case 3: Shortcut: pnvm dev, pnvm build, etc.
REM → maps to: npm run <script>
REM ------------------------------------------------------------
"%NPM_CMD%" run %FIRST_ARG% %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%
