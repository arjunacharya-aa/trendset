@echo off
echo Starting HTTP Server on http://localhost:8000/
echo Opening browser...
start http://localhost:8000/
powershell -ExecutionPolicy Bypass -File start-server.ps1



