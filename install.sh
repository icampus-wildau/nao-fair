#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$root/nao-fair-server/pyproject.toml" || ! -f "$root/nao-fair-frontend/pnpm-lock.yaml" ]]; then
  echo 'Server or frontend checkout is missing. From this repository run: git submodule update --init' >&2
  exit 1
fi

missing=0
if ! command -v uv >/dev/null 2>&1; then
  echo 'uv is missing. Install it from https://docs.astral.sh/uv/getting-started/installation/' >&2
  missing=1
fi

python_ok=0
if command -v python3.12 >/dev/null 2>&1; then
  python_ok=1
elif command -v python3 >/dev/null 2>&1 && [[ "$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')" == "3.12" ]]; then
  python_ok=1
elif command -v python >/dev/null 2>&1 && [[ "$(python -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')" == "3.12" ]]; then
  python_ok=1
fi
if [[ "$python_ok" -ne 1 ]]; then
  echo 'Python 3.12 is missing from PATH. Install it from https://www.python.org/downloads/release/python-3120/' >&2
  missing=1
fi

if ! command -v node >/dev/null 2>&1 || ! command -v pnpm >/dev/null 2>&1; then
  echo 'Node.js and pnpm are missing. Install Node.js 20.19+ or 22.12+ from https://nodejs.org/ and pnpm from https://pnpm.io/installation' >&2
  missing=1
elif ! node -e 'const [maj, min] = process.versions.node.split(".").map(Number); const ok = (maj === 20 && min >= 19) || maj > 22 || (maj === 22 && min >= 12); process.exit(ok ? 0 : 1)'; then
  echo "Node.js $(node --version) is not supported. Install Node.js 20.19+ or 22.12+ from https://nodejs.org/" >&2
  missing=1
fi

if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

cd "$root/nao-fair-server"
uv sync --locked --extra dev --extra browser --extra robot
mkdir -p -m 700 .venv/nltk_data
uv run python -m nltk.downloader -d .venv/nltk_data punkt_tab

cd "$root/nao-fair-frontend"
pnpm install --frozen-lockfile

echo 'NAO Fair is installed. Start it with ./start-nao-fair.sh or ./start-nao-fair-dev.sh'
