@echo off
REM Doble clic para preparar el proyecto (genera android/ y windows/)
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\setup.ps1"
pause
