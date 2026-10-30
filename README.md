# Chrome remote (noVNC)

Google Chrome Stable (Chromium on arm64) in a container, reachable from a web browser. Built on
`jlesage/baseimage-gui` (the same base as `jlesage/docker-firefox`); we only replace the app layer.
Decision: own thin Dockerfile instead of a fork — Firefox's repo carries Alpine/NSPR/membarrier
patches Chrome doesn't need, and a fork would mean merging them forever.

## Run
    docker compose up -d --build
Open `http://localhost:5800` → Chrome. Sign in to Google inside Chrome; Sync works and is stored in the volume.

## Test
    docker build -t chrome-remote .            # add --build-arg BROWSER=chromium for arm64
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
| `BROWSER` (build arg) | `chrome` | `chrome` or `chromium` |
| `CHROME_ARGS` | – | Extra Chrome flags |

All other base-image variables: https://github.com/jlesage/docker-baseimage-gui

## Notes
- `BROWSER=chrome` (default) is amd64 only: Google ships no arm64 Linux Chrome, so the build fails on arm64 with a clear message.
- `BROWSER=chromium` works on any arch (e.g. arm64), but Chrome Sync is unreliable in Chromium without Google API keys.
- Runs with `--no-sandbox` (container default). Chrome `current` is fetched at build time: rebuild to update.
- Keep `shm_size` ≥ 1 GB or tabs crash.
