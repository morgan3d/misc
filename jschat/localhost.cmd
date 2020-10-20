@echo off
if "%1" == "/launch" goto launch

start /b localhost.cmd /launch > NUL
python -m http.server

goto end

:launch
REM Delayed launch
timeout /t 1 /nobreak
start http://localhost:8000/index.html

:end