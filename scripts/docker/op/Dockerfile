# Thin wrapper around the public OpenClaw runtime image that adds the
# 1Password CLI. Rebuilt by .github/workflows/build-op-image.yml so hosts
# only ever `docker pull`; nothing is compiled locally.
ARG OPENCLAW_BASE_IMAGE="ghcr.io/openclaw/openclaw:latest"
FROM ${OPENCLAW_BASE_IMAGE}

USER root

RUN --mount=type=cache,id=openclaw-op-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=openclaw-op-apt-lists,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg && \
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | gpg --dearmor > /tmp/1password.gpg && \
    install -d -m 0755 /etc/apt/keyrings && \
    mv /tmp/1password.gpg /etc/apt/keyrings/1password.gpg && \
    printf 'deb [arch=%s signed-by=/etc/apt/keyrings/1password.gpg] https://downloads.1password.com/linux/debian/amd64 stable main\n' \
      "$(dpkg --print-architecture)" > /etc/apt/sources.list.d/1password.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends 1password-cli

USER node
