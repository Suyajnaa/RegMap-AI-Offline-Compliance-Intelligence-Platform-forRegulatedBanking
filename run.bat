@echo off
REM RegMap AI -- start the app (Windows)
REM Run setup.bat first if you haven't already.

if not exist "backend\venv" (
    echo No backend\venv found. Run setup.bat first.
    exit /b 1
)

if not exist "frontend\node_modules" (
    echo Frontend dependencies aren't installed. Run setup.bat first.
    exit /b 1
)

echo Starting backend on http://localhost:5000 ...
start "RegMap AI - Backend" cmd /k "cd backend && call venv\Scripts\activate.bat && python app.py"

timeout /t 3 /nobreak >nul

echo Starting frontend on http://localhost:5173 ...
start "RegMap AI - Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo Both servers are starting in their own windows.
echo Open http://localhost:5173 in your browser once they're ready.
echo Close those two windows to stop the app.
