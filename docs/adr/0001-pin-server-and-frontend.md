# Pin the server and frontend as submodules

The NAO Fair app is split into nao-fair-server and nao-fair-frontend, and a running pair has to match. This repository records an exact commit of each as a submodule. Advancing either checkout is a commit here.

## Considered options

- Two manual clones, as the server install guide described. Nothing recorded which commits belong together.
- Submodules that follow a branch tip. A pull on a fair laptop would change the app without a review.
