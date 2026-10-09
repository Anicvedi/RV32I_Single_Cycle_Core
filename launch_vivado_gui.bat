@echo off
REM ==============================================================================
REM Launch Vivado GUI for Single-Cycle 32-bit RISC-V Processor Project
REM Author: Anirudh Chaturvedi
REM ==============================================================================

set "VIVADO_BIN=C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat"
set "PROJ_XPR=C:\temp\RV32I_Single_Cycle_Core\vivado\RV32I_Single_Cycle_Core.xpr"
set "CREATE_TCL=C:\temp\RV32I_Single_Cycle_Core\scripts\create_vivado_project.tcl"

if not exist "%VIVADO_BIN%" (
    echo [ERROR] Vivado executable was not found at %VIVADO_BIN%
    pause
    exit /b 1
)

if exist "%PROJ_XPR%" (
    echo [INFO] Existing Vivado project found: %PROJ_XPR%
    echo [INFO] Launching Vivado GUI...
    start "" "%VIVADO_BIN%" "%PROJ_XPR%"
    exit /b 0
)

echo [INFO] Project does not exist yet. Generating project via Vivado and launching GUI...
start "" "%VIVADO_BIN%" -mode gui -source "%CREATE_TCL%"
exit /b 0
