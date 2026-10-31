# Chrome remote (noVNC)

Google Chrome Stable (amd64 and arm64) in a container, reachable from a web browser. Built on
`jlesage/baseimage-gui` (the same base as `jlesage/docker-firefox`); we only replace the app layer.
Decision: own thin Dockerfile instead of a fork — Firefox's repo carries Alpine/NSPR/membarrier
patches Chrome doesn't need, and a fork would mean merging them forever.

## Run
Prebuilt multi-arch image: `ghcr.io/rpolverini/docker-chrome:latest`. Or build locally:

    docker compose up -d --build
Open `http://localhost:5800` → Chrome. Sign in to Google inside Chrome; Sync works and is stored in the volume.

## Test
    docker build -t chrome-remote .
    docker run --rm -p 5800:5800 --shm-size=2g -v chrome-config:/config chrome-remote
Open http://localhost:5800, sign in to Google in Chrome and enable Sync. Recreate the container and check you're still signed in (volume persistence).

## Coolify
New resource → Docker Compose (this repo), domain → port `5800`. There is **no login in the container**: put Cloudflare Access (or similar) in front. Anyone reaching the port controls the browser and your Google session.

## Ports
| Port | Use |
|------|-----|
| 5800 | Web UI (noVNC) |
| 5900 | Raw VNC (not published by default) |

## Volumes
| Path | Use |
|------|-----|
| `/config` | Chrome profile (`/config/profile`), logs, baseimage config. Must be persistent. |

## Environment variables
| Var | Default | Meaning |
|-----|---------|---------|
| `WEB_AUTHENTICATION`, `WEB_AUTHENTICATION_USERNAME`, `WEB_AUTHENTICATION_PASSWORD` | off | Optional web login (needs `SECURE_CONNECTION=1`); add to compose if wanted |
| `SECURE_CONNECTION` | `0` | HTTPS/WSS for the web UI |
| `VNC_PASSWORD` | – | Password for raw VNC port 5900 |
| `DISPLAY_WIDTH` / `DISPLAY_HEIGHT` | 1920 / 1080 | Screen size |
| `USER_ID` / `GROUP_ID` | 1000 / 1000 | Owner of files in `/config` |
| `CHROME_ARGS` | – | Extra Chrome flags |

All other base-image variables: https://github.com/jlesage/docker-baseimage-gui

## Notes
- Multi-arch: amd64 and arm64 both install Google's official Chrome `.deb` (arm64 published by Google in 2026). Image is published to GHCR for both.
- Runs with `--no-sandbox` (container default). Chrome `current` is fetched at build time: rebuild to update.
- Keep `shm_size` ≥ 1 GB or tabs crash.
