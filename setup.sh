#!/bin/bash
# RegMap AI — one-time setup (macOS / Linux)
# Installs everything needed to run the app. Run this once.
# After this finishes, use ./run.sh to start the app.

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

step() { echo -e "\n${GREEN}==> $1${NC}"; }
fail() { echo -e "${RED}✗ $1${NC}"; exit 1; }

# Find a working python command
PYTHON_CMD=""
for cmd in python3 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        PYTHON_CMD="$cmd"
        break
    fi
done
[ -z "$PYTHON_CMD" ] && fail "Python was not found. Install Python 3.9+ from https://www.python.org/downloads/ and try again."

PY_VERSION=$("$PYTHON_CMD" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
step "Found Python $PY_VERSION ($PYTHON_CMD)"

command -v node >/dev/null 2>&1 || fail "Node.js was not found. Install Node 18+ from https://nodejs.org/ and try again."
step "Found Node $(node --version)"

step "Creating Python virtual environment (backend/venv)..."
cd backend
"$PYTHON_CMD" -m venv venv
source venv/bin/activate

step "Installing backend dependencies (this can take a few minutes)..."
pip install --upgrade pip -q
pip install -r requirements.txt -q

step "Downloading local NLP models (one-time, needs internet for this step only)..."
python setup_models.py

deactivate
cd ..

if [ ! -f .env ]; then
    step "Creating .env from .env.example..."
    cp .env.example .env
else
    step ".env already exists, leaving it as-is."
fi

step "Installing frontend dependencies..."
cd frontend
npm install --silent
cd ..

echo -e "\n${GREEN}Setup complete.${NC} Start the app with:\n"
echo -e "  ${GREEN}./run.sh${NC}\n"
echo "Then open http://localhost:5173 in your browser."
