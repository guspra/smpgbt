@echo off
setlocal

set IMAGE_NAME=smpgbt
set CONTAINER_NAME=smpgbt-run
set ENV_FILE=.env
set SCREENSHOT=proof.png

echo.
echo [%date% %time%] Building %%IMAGE_NAME%% image...

if not exist "%ENV_FILE%" (
    echo Environment file "%ENV_FILE%" not found. Aborting.
    exit /b 1
)

docker build -t "%IMAGE_NAME%" .
if errorlevel 1 (
    echo Docker build failed. Aborting.
    exit /b 1
)

echo Cleaning up any leftover container...
docker rm -f "%CONTAINER_NAME%" >nul 2>&1

echo Running container "%CONTAINER_NAME%"...
docker run --name "%CONTAINER_NAME%" --env-file "%ENV_FILE%" "%IMAGE_NAME%"
set RUN_RESULT=%ERRORLEVEL%

if not "%RUN_RESULT%"=="0" (
    echo Container exited with code %RUN_RESULT%.
    echo Showing last logs:
    docker logs "%CONTAINER_NAME%" 2>nul
    docker rm -f "%CONTAINER_NAME%" >nul 2>&1
    exit /b %RUN_RESULT%
)

echo Copying screenshot to "%SCREENSHOT%"...
docker cp "%CONTAINER_NAME%:/app/proof.png" "%SCREENSHOT%"
if errorlevel 1 (
    echo Failed to copy screenshot from container.
) else (
    echo Screenshot saved to "%SCREENSHOT%".
)

docker rm "%CONTAINER_NAME%" >nul 2>&1

echo Done.
exit /b 0
