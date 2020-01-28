:: ************************************************************************************
:: * Copyright (C) 2019                                                               *
:: * TETCOS, Bangalore. India                                                         *
:: *                                                                                  *
:: * Tetcos owns the intellectual property rights in the Product and its content.     *
:: * The copying, redistribution, reselling or publication of any or all of the       *
:: * Product or its content without express prior written consent of Tetcos is        *
:: * prohibited. Ownership and / or any other right relating to the software and all  *
:: * intellectual property rights therein shall remain at all times with Tetcos.      *
:: *                                                                                  *
:: * Author:  Kundrapu Dilip Kumar                                                     *
:: * Date:    08-03-2019                                                                              *
:: * ---------------------------------------------------------------------------------*

@ECHO OFF

setlocal
REM - NetSim will not ask for key press after simulation starts
SET NETSIM_AUTO=1 
REM - Windows won't pop-up GUI screen for error reporting
SET NETSIM_ERROR_MODE=1 
endlocal

REM - This will restrict the AutoTest.bat to open by double clicking without arguments
if [%1] == [] (
	if [%2] == [] (
		exit
	)
)

REM - Arguments from user input
SET APP_PATH=%1
SET LICENSE=%2

setlocal EnableDelayedExpansion

if exist results.txt (
	DEL results.txt
)

if exist "%Temp%\NetSimCoreAuto" (
	RD /Q /S "%Temp%\NetSimCoreAuto"
)

REM - Creates a folder in the %TEMP%
MD "%Temp%\NetSimCoreAuto"

REM - For all the directories/sub-directories which contain .netsim file
for /r %%i in (*.netsim) do (

	COPY "%%~dpi" "%Temp%\NetSimCoreAuto"	
	
	if exist "%%~dpi\Metrics.xml" (

		DEL "%Temp%\NetSimCoreAuto\Metrics.xml"

		REM - Runs the simulation 
		START "" /w %APP_PATH%\NetSimCore.exe -apppath %APP_PATH% -iopath "%Temp%\NetSimCoreAuto" -license %LICENSE%

		REM - If the Metrics.xml doesn't exist then it indicates that the simulation crashed
		if exist "%Temp%\NetSimCoreAuto\Metrics.xml" (	
		
			REM - Compares the Metrics.xml files  
			FC "%%~dpi\Metrics.xml" "%Temp%\NetSimCoreAuto\Metrics.xml" > "%Temp%\NetSimCoreAuto\tmp.txt"
        
			REM - If the previous command gives an errorlevel equal to or greater
			if errorlevel 1 (
				echo %%~dpi - Difference >> results.txt
			) else (
					  echo %%~dpi - Success >> results.txt
				   )
		) else (
				  echo %%~dpi - Crashed >> results.txt
			   )
		
		echo -----------------------------------------------------------------------------

	) else (
				echo %%~dpi - Missing 'Metrics.xml' >> results.txt
		   )
)

REM - Removes the folder from the %TEMP%
rem RD /Q /S "%Temp%\NetSimCoreAuto"
PAUSE