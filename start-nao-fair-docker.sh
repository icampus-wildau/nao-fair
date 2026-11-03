#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$root"

if [[ ! -f nao-fair-server/pyproject.toml || ! -f nao-fair-frontend/package-lock.json ]]; then
  echo 'Server or frontend checkout is missing. From this repository run: git submodule update --init' >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo 'Docker is missing. Install Docker Engine and the Compose plugin: https://docs.docker.com/engine/install/' >&2
  exit 1
fi

mkdir -p nao-fair-server/data
chmod 700 nao-fair-server/data

export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

echo 'NAO Fair production container:'
echo '  Web UI: http://127.0.0.1:8000'
echo 'Stop with Ctrl+C.'

exec docker compose up --build
