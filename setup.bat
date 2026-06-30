@echo off
REM RegMap AI -- one-time setup (Windows)
REM Installs everything needed to run the app. Run this once.
REM After this finishes, use run.bat to start the app.

setlocal enabledelayedexpansion

where python >nul 2>nul
if errorlevel 1 (
    echo Python was not found. Install Python 3.9+ from https://www.python.org/downloads/
    echo IMPORTANT: check "Add Python to PATH" during install.
    exit /b 1
)
echo Found Python:
python --version

where node >nul 2>nul
if errorlevel 1 (
    echo Node.js was not found. Install Node 18+ from https://nodejs.org/
    exit /b 1
)
echo Found Node:
node --version

echo.
echo ==^> Creating Python virtual environment (backend\venv)...
cd backend
python -m venv venv
call venv\Scripts\activate.bat

echo.
echo ==^> Installing backend dependencies (this can take a few minutes)...
python -m pip install --upgrade pip -q
pip install -r requirements.txt -q

echo.
echo ==^> Downloading local NLP models (one-time, needs internet for this step only)...
python setup_models.py

call venv\Scripts\deactivate.bat
cd ..

if not exist .env (
    echo.
    echo ==^> Creating .env from .env.example...
    copy .env.example .env >nul
) else (
    echo .env already exists, leaving it as-is.
)

echo.
echo ==^> Installing frontend dependencies...
cd frontend
call npm install
cd ..

echo.
echo Setup complete. Start the app with:
echo.
echo     run.bat
echo.
echo Then open http://localhost:5173 in your browser.
