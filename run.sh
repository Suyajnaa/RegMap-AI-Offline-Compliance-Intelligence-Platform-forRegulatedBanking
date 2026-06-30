#!/bin/bash
# RegMap AI — start the app (macOS / Linux)
# Run ./setup.sh first if you haven't already.

set -e

if [ ! -d "backend/venv" ]; then
    echo "No backend/venv found. Run ./setup.sh first."
    exit 1
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "Frontend dependencies aren't installed. Run ./setup.sh first."
    exit 1
fi

cleanup() {
    echo -e "\nStopping..."
    kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null
    wait "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null
    exit 0
}
trap cleanup INT TERM

echo "Starting backend on http://localhost:5000 ..."
(cd backend && source venv/bin/activate && python app.py) &
BACKEND_PID=$!

sleep 2

echo "Starting frontend on http://localhost:5173 ..."
(cd frontend && npm run dev) &
FRONTEND_PID=$!

echo -e "\nBoth servers are running. Open http://localhost:5173 in your browser."
echo "Press Ctrl+C to stop both.\n"

wait
