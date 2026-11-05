# nao-fair

*Install and start the operator app for one NAO at a university fair.*

![Python](https://img.shields.io/badge/python-3.12-blue?style=flat-square)
![Node](https://img.shields.io/badge/node-20.19%20%7C%2022.12%2B-blue?style=flat-square)
![License: Apache 2.0](https://img.shields.io/badge/license-Apache%20License%202.0-blue)

This repository pins [nao-fair-server](https://github.com/icampus-wildau/nao-fair-server) and [nao-fair-frontend](https://github.com/icampus-wildau/nao-fair-frontend) and supplies the install and start commands.

Use it to run the booth app, or to edit prompts, knowledge, and sensor mappings before a robot is connected. An API-only server setup stays in the [server README](https://github.com/icampus-wildau/nao-fair-server#setup).

## Requirements

Linux x86-64. The robot extra needs Python 3.12, and the locked `qi` wheel has no Windows or Linux ARM build.

- Git, [uv](https://docs.astral.sh/uv/getting-started/installation/), Python 3.12
- Node.js 20.19+ or 22.12+, with [pnpm](https://pnpm.io/installation)
- Docker Engine with the Compose plugin, only for the production container

A robot and cloud keys are not required to edit configuration. For a real conversation, set the Gladia and OpenAI keys, reach the NAO on TCP 9559 or 9561 and 8765, and install the [robot microphone bridge](https://github.com/icampus-wildau/nao-websocket-bridge#install-from-a-laptop).

## Install and start

```bash
git clone --recurse-submodules https://github.com/icampus-wildau/nao-fair.git
cd nao-fair
git submodule update --init   # only if the clone omitted submodules
./install.sh                  # server extras, NLTK data, frontend deps; does not build or start
./start-nao-fair.sh           # builds the UI, serves http://127.0.0.1:8000
```

Ctrl+C stops the server. Restart after backend changes, and free port 8000 first.

Development, with frontend reload at [http://127.0.0.1:5173](http://127.0.0.1:5173) and the API still on port 8000:

```bash
./start-nao-fair-dev.sh   # Ctrl+C stops both; backend changes still need a restart
```

OpenAI and Gladia keys are set in the app under **System → Schlüssel**, or with `OPENAI_API_KEY` and `GLADIA_API_KEY`. `NAO_BRIDGE_TOKEN` is the microphone-bridge path token.

## Production container

```bash
./start-nao-fair-docker.sh   # linux/amd64, host network, foreground; Ctrl+C stops it
```

Open [http://127.0.0.1:8000](http://127.0.0.1:8000). The image contains the built frontend and the server with the robot and browser extras. `nao-fair-server/data` is bind-mounted, so the container and `./start-nao-fair.sh` share the database and operator secrets. The container runs as the current user.

On Docker Desktop, use Linux containers and enable **Settings → Resources → Network → Enable host networking**.

## Windows

Native Windows cannot install the robot extra. For the scripts above, use WSL 2 and open [http://127.0.0.1:8000](http://127.0.0.1:8000) in a Windows browser.

To edit the server in a dev container, open `nao-fair-server` and choose **Dev Containers: Reopen in Container**. The frontend still runs on the host: `./start-nao-fair-dev.sh` from this repository, or `pnpm run dev` in `nao-fair-frontend`. The container uses the host network, so the host dev server reaches the API on port 8000.

## Without a robot

Prompts, knowledge, pronunciation, vocabulary, sensor mappings, dialogs, and scenarios can be edited and saved while no robot is connected. Loading a scenario fills the draft; **Übernehmen** applies configuration. Hardware actions stay unavailable.

**System → Tests** runs the conversation with the browser microphone. With no robot connected, **Gespräch ohne NAO testen** on the dashboard opens that screen. The microphone starts only from **Mikrofontest starten**. Requirements are in the server README, [Test the conversation without a NAO](https://github.com/icampus-wildau/nao-fair-server#test-the-conversation-without-a-nao).

## Checks

From `nao-fair-frontend`:

```bash
pnpm test
pnpm run typecheck
pnpm run test:e2e   # production client, API on 8001, preview on 4183; both ports must be free
```

The test server uses a temporary directory and does not read operator data. Browser choice and the Python path are in the [frontend README](https://github.com/icampus-wildau/nao-fair-frontend).

## Move a pinned checkout

The server and frontend stay on the commits recorded here. Pulling this repository does not move either checkout to that day's `main`.

```bash
git -C nao-fair-server fetch origin
git -C nao-fair-server checkout origin/main
# same two commands with nao-fair-frontend
```

Review the pair, then commit the new submodule pointers.

## Decisions

Domain language, runtime rules, and server decisions are in the server's
[glossary](nao-fair-server/GLOSSARY.md), [behavior reference](nao-fair-server/docs/behavior.md),
and [ADR index](nao-fair-server/docs/adr/README.md). The
[frontend requirements](nao-fair-frontend/requirements.md) describe the current UI.

- [Pin the server and frontend as submodules](docs/adr/0001-pin-server-and-frontend.md)
- [Run production Docker on the host network](docs/adr/0002-production-docker-host-network.md)
