# nao-fair

The NAO Fair app is the operator application for one NAO robot at a university fair. This repository pins [nao-fair-server](https://github.com/icampus-wildau/nao-fair-server) and [nao-fair-frontend](https://github.com/icampus-wildau/nao-fair-frontend) and supplies the install and start commands.

## Requirements

Linux x86-64. The robot libraries need Python 3.12, and the locked `qi` wheel has no Windows or Linux ARM build.

- Git
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- Python 3.12
- Node.js 20.19+ or 22.12+, with npm
- Docker Engine with the Compose plugin, when using the production container

A robot and cloud keys are not required to edit configuration. For a real conversation, set the Gladia and OpenAI keys, reach the NAO on TCP 9559 or 9561 and 8765, and install the [robot microphone bridge](https://github.com/icampus-wildau/nao-websocket-bridge#install-from-a-laptop).

## Clone

```bash
git clone --recurse-submodules https://github.com/icampus-wildau/nao-fair.git
cd nao-fair
```

If the clone was made without submodules:

```bash
git submodule update --init
```

## Install

```bash
./install.sh
```

The script checks that `uv`, Python 3.12, and Node.js are on `PATH`. It then installs the server with the dev, browser, and robot extras, downloads the NLTK `punkt_tab` data, and installs the frontend dependencies. It does not build the frontend and does not start the app.

An API-only setup of the server, without the robot extra, stays in the [server README](https://github.com/icampus-wildau/nao-fair-server#setup).

## Start

Production. The built app is served at [http://127.0.0.1:8000](http://127.0.0.1:8000):

```bash
./start-nao-fair.sh
```

Stop with Ctrl+C. The script builds the frontend, then starts the server. Restart it after backend changes, and stop any process already bound to port 8000 first.

Development. Frontend hot reload is at [http://127.0.0.1:5173](http://127.0.0.1:5173), and the API stays at [http://127.0.0.1:8000](http://127.0.0.1:8000):

```bash
./start-nao-fair-dev.sh
```

Ctrl+C stops both processes. Frontend changes reload. Backend changes need a restart.

OpenAI and Gladia keys are set in the app under **System → Schlüssel**, or with `OPENAI_API_KEY` and `GLADIA_API_KEY`. `NAO_BRIDGE_TOKEN` is the microphone-bridge path token.

## Production with Docker

```bash
./start-nao-fair-docker.sh
```

The script builds a `linux/amd64` image when the build inputs changed, then runs it in the foreground on the host network. Open [http://127.0.0.1:8000](http://127.0.0.1:8000). Ctrl+C stops the container.

The image contains the built frontend and the server with the robot and browser extras. `nao-fair-server/data` is bind-mounted, so the container and `./start-nao-fair.sh` share the database and operator secrets. The container runs as the current user.

On Docker Desktop, use Linux containers and enable **Settings → Resources → Network → Enable host networking**.

## Windows

Native Windows cannot install the robot extra. For the local scripts, use WSL 2, run the Linux commands above inside it, and open [http://127.0.0.1:8000](http://127.0.0.1:8000) in a Windows browser.

To edit the server in a dev container, open `nao-fair-server` in VS Code or Cursor and choose **Dev Containers: Reopen in Container**. That container is the editor environment. It installs the server dependencies when it starts. The frontend still runs on the host: `./start-nao-fair-dev.sh` from this repository, or `npm run dev` in `nao-fair-frontend`. The dev container uses the host network, so the host dev server reaches the API on port 8000.

## Use without a robot

Prompts, knowledge, pronunciation, vocabulary, sensor mappings, presets, and setups can be edited, saved, and applied while no robot is connected. Hardware actions stay unavailable. Editing does not need cloud access.

**System → Tests** runs the conversation with the browser microphone. Requirements are in the server README, [Test the conversation without a NAO](https://github.com/icampus-wildau/nao-fair-server#test-the-conversation-without-a-nao). With no robot connected, **Gespräch ohne NAO testen** on the dashboard opens that screen. The microphone starts only from **Mikrofontest starten**.

## Checks

From `nao-fair-frontend`:

```bash
npm test
npm run typecheck
npm run test:e2e
```

`npm run test:e2e` builds the production client and starts its own server on port 8001 and a preview on port 4183. Both ports must be free. The test server uses a temporary directory and does not read operator data. Browser choice and the Python path are described in the [frontend README](https://github.com/icampus-wildau/nao-fair-frontend).

## Update a pinned checkout

The server and frontend stay on the commits recorded here. To move the server forward:

```bash
git -C nao-fair-server fetch origin
git -C nao-fair-server checkout origin/main
```

Use `nao-fair-frontend` for the other checkout. Review the pair, then commit the new submodule pointers in this repository. Pulling this repository does not move either checkout to whatever `main` is that day.

## Decisions

- [Pin the server and frontend as submodules](docs/adr/0001-pin-server-and-frontend.md)
- [Run production Docker on the host network](docs/adr/0002-production-docker-host-network.md)
