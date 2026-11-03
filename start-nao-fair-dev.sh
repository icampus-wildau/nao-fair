#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
python="$root/nao-fair-server/.venv/bin/python"

if [[ ! -x "$python" ]]; then
  echo 'Python environment is missing. Run ./install.sh first. On Windows, use WSL. See README.md.' >&2
  exit 1
fi

cd "$root/nao-fair-frontend"
if [[ ! -d node_modules ]]; then
  npm ci
fi

backend_pid=""
frontend_pid=""

cleanup() {
  local pid
  for pid in "$frontend_pid" "$backend_pid"; do
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
  done
  for pid in "$frontend_pid" "$backend_pid"; do
    if [[ -n "$pid" ]]; then
      wait "$pid" 2>/dev/null || true
    fi
  done
}

trap cleanup EXIT INT TERM

export NLTK_DATA="$root/nao-fair-server/.venv/nltk_data"
cd "$root/nao-fair-server"
"$python" -m nao_fair &
backend_pid=$!

sleep 1
if ! kill -0 "$backend_pid" 2>/dev/null; then
  echo 'Backend failed to start. Port 8000 may already be in use.' >&2
  exit 1
fi

echo 'NAO Fair development:'
echo '  Web UI (hot reload): http://127.0.0.1:5173'
echo '  API:                 http://127.0.0.1:8000'
echo 'Stop with Ctrl+C.'

cd "$root/nao-fair-frontend"
npm run dev &
frontend_pid=$!
wait "$frontend_pid"
