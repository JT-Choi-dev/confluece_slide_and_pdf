@echo off
echo === Confluence PDF Exporter 시작 중... ===

:: venv 활성화
call venv\Scripts\activate

:: 브라우저 자동 오픈 (2초 후)
start /b cmd /c "timeout /t 2 >nul && start http://localhost:5001"

:: Flask 서버 시작
python app.py
