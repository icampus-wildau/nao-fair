# Run production Docker on the host network

The production image is one linux/amd64 container: the server with the robot and browser extras, plus the built frontend. It joins the host network and listens on 127.0.0.1:8000. The operator UI has no login, so a published port would expose it on the fair network. Host networking also lets the process reach the robot on ports 9559, 9561, and 8765. The bind-mounted server data directory holds the database and the operator secrets, and a local start uses that same directory.

## Considered options

- Bridge networking with port 8000 published. That would bind the UI on the machine's network interfaces.
- Reusing the server dev container. That image is an editor environment and does not build the frontend.
