@echo off
REM ==============================================================================
REM Launch Vivado GUI for Single-Cycle 32-bit RISC-V Processor Project
REM Author: Anirudh Chaturvedi
REM ==============================================================================

set "VVGL=C:\AMDDesignTools\2025.2\Vivado\bin\unwrapped\win64.o\vvgl.exe"
set "VIVADO_BAT=C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
set "PROJ_XPR=C:\temp\RV32I_Single_Cycle_Core\vivado\RV32I_Single_Cycle_Core.xpr"

if not exist "%VVGL%" (
    echo [ERROR] Vivado launcher was not found at %VVGL%
    pause
    exit /b 1
)

echo [INFO] Launching Vivado 2025.2 GUI with %PROJ_XPR%...
start "" "%VVGL%" "%VIVADO_BAT%" "%PROJ_XPR%"
exit /b 0
