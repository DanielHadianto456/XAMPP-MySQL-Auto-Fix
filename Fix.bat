@echo off
setlocal enabledelayedexpansion

REM Ensure the batch file is being run from the mysql directory
if not exist "%CD%\data" (
    echo This batch file must be placed inside the mysql directory.
    echo Exiting...
    pause
    exit /b
)

REM Step 1: Find the next available data_old directory name with an incrementing number
set count=1
:checkdir
if exist "%CD%\data_old!count!" (
    set /a count+=1
    goto checkdir
)

set newDataOldDir=data_old!count!
echo Renaming data to %newDataOldDir%...
ren "%CD%\data" "%newDataOldDir%"

REM Step 2: Make a copy of mysql/backup folder and name it as mysql/data
echo Copying backup to data...
xcopy /E /I "%CD%\backup" "%CD%\data"

REM Step 3: Copy all database folders from %newDataOldDir% into data (excluding certain folders)
echo Copying databases from %newDataOldDir% to data (excluding mysql, performance_schema, and phpmyadmin)...
for /d %%G in ("%CD%\%newDataOldDir%\*") do (
    if /I not "%%~nxG"=="mysql" if /I not "%%~nxG"=="performance_schema" if /I not "%%~nxG"=="phpmyadmin" (
        xcopy /E /I "%%G" "%CD%\data\%%~nxG"
    )
)

REM Step 4: Copy ibdata1 file from %newDataOldDir% to data
echo Copying ibdata1 from %newDataOldDir% to data...
copy "%CD%\%newDataOldDir%\ibdata1" "%CD%\data\ibdata1"

echo All done!
pause
