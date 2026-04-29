@echo off
echo === Confluence PDF Exporter - 초기 설정 ===
echo.

:: venv 생성
python -m venv venv
echo [1/3] 가상환경 생성 완료

:: 패키지 설치
call venv\Scripts\activate
pip install -r requirements.txt
echo [2/3] 패키지 설치 완료

:: Playwright Chromium 설치
playwright install chromium
echo [3/3] Playwright Chromium 설치 완료

echo.
echo === 설정 완료! 이제 start.bat 을 실행하세요 ===
pause
