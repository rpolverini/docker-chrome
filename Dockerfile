# Google Chrome Stable behind noVNC, built on jlesage/baseimage-gui (same base as jlesage/docker-firefox).
# Multi-arch: amd64 and arm64 both use Google's official .deb.
FROM jlesage/baseimage-gui:debian-12-v4.14.0

# /var/log -> /config/log in the base image; dangling at build time, which breaks systemd's postinst.
RUN mkdir -p /config/log && apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates fonts-liberation && \
    wget -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_$(dpkg --print-architecture).deb" && \
    apt-get install -y --no-install-recommends /tmp/chrome.deb && rm /tmp/chrome.deb && \
    rm -rf /var/lib/apt/lists/*

COPY rootfs/ /

RUN set-cont-env APP_NAME "Chrome"
