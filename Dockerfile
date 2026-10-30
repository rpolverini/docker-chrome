# Browser behind noVNC, built on jlesage/baseimage-gui (same base as jlesage/docker-firefox).
# BROWSER=chrome (default, amd64 only: Google ships no arm64 Linux Chrome) or BROWSER=chromium (any arch).
FROM jlesage/baseimage-gui:debian-12-v4.14.0

ARG BROWSER=chrome

RUN apt-get update && \
    if [ "$BROWSER" = "chromium" ]; then \
        apt-get install -y --no-install-recommends chromium fonts-liberation; \
    elif [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        apt-get install -y --no-install-recommends wget ca-certificates fonts-liberation && \
        wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
        apt-get install -y --no-install-recommends /tmp/chrome.deb && rm /tmp/chrome.deb; \
    else \
        echo "Google Chrome has no $(dpkg --print-architecture) build; use --build-arg BROWSER=chromium" >&2; exit 1; \
    fi && \
    rm -rf /var/lib/apt/lists/*

COPY rootfs/ /

RUN set-cont-env APP_NAME "Chrome"
