#!/bin/sh
set -eu

mkdir -p /config/profile /config/log
# Stale locks from a previous container (different hostname) make Chrome refuse the profile.
rm -f /config/profile/SingletonLock /config/profile/SingletonCookie /config/profile/SingletonSocket

# --no-sandbox: the container has no user namespaces by default.
# --password-store=basic: no keyring in the container; keeps Sync/login state in the profile.
exec google-chrome-stable \
    --user-data-dir=/config/profile \
    --no-sandbox \
    --password-store=basic \
    --no-first-run \
    --no-default-browser-check \
    --disable-dev-shm-usage \
    --start-maximized \
    ${CHROME_ARGS:-} "$@" \
    >> /config/log/chrome.log 2>&1
