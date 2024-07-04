@echo off

REM init-localhost.bat - Initialize for running vault.

REM Check if USERPROFILE environment variable is not set.
if "%HOMEPATH%"=="" (
  echo Error: the HOMEPATH environment variable is not set.
  exit /b 1
)

REM Define HOME based on USERPROFILE.
set HOME=%HOMEPATH%

REM Create the necessary directories for Vault data and configuration.
mkdir "%HOME%\.vault"
mkdir "%HOME%\.vault\uhgroupings"
mkdir "%HOME%\.vault\uhgroupings\data"
mkdir "%HOME%\.vault\uhgroupings\config"

rem Check if the directory is not empty.
dir /b /a "%HOME%\.vault\uhgroupings\data" | findstr "^" >nul
if %ERRORLEVEL% EQU 0 (
    echo Info: removed existing vault data to ensure a fresh init.
    del /q /s "%HOME%\.vault\uhgroupings\data\*"
    for /d %%x in ("%HOME%\.vault\uhgroupings\data\*") do @rd /s /q "%%x"
)

REM Copy the Vault configuration file to the appropriate directory.
copy "vault-config.hcl" "%HOME%\.vault\uhgroupings\config"

REM Start the Vault container using Docker Compose.
docker-compose up -d

REM Check if Docker Compose started successfully.
if %ERRORLEVEL% EQU 0 (
  echo Success: the vault container started successfully.
) else (
  echo Error: failed to start the Vault container.
  exit /b 1
)

exit /b 0
