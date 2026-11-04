FROM node:22-bookworm-slim AS frontend

WORKDIR /src/nao-fair-frontend
COPY nao-fair-frontend/package.json nao-fair-frontend/pnpm-lock.yaml ./
RUN corepack enable && corepack install && pnpm install --frozen-lockfile
COPY nao-fair-frontend/ ./
RUN pnpm run build

FROM python:3.12-slim-bookworm AS runtime

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /opt/nao-fair
COPY nao-fair-server /opt/nao-fair/nao-fair-server
COPY --from=frontend /src/nao-fair-frontend/dist /opt/nao-fair/nao-fair-frontend/dist

WORKDIR /opt/nao-fair/nao-fair-server
ENV UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/nao-fair/nao-fair-server/.venv \
    NLTK_DATA=/opt/nao-fair/nao-fair-server/.venv/nltk_data \
    PYTHONUNBUFFERED=1

RUN uv sync --locked --extra robot --extra browser --compile-bytecode \
    && mkdir -p -m 755 "$NLTK_DATA" \
    && uv run python -m nltk.downloader -d "$NLTK_DATA" punkt_tab \
    && mkdir -p data

EXPOSE 8000
CMD [".venv/bin/python", "-m", "nao_fair"]
