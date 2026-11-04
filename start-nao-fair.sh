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
  pnpm install --frozen-lockfile
fi
pnpm run build

export NLTK_DATA="$root/nao-fair-server/.venv/nltk_data"
cd "$root/nao-fair-server"
exec "$python" -m nao_fair
