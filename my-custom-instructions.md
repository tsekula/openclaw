# My Custom OpenClaw Setup (v2 branch)

This document captures every customization made to the `v2` branch of this fork
that differs from upstream `openclaw/openclaw` `main`. It is intended as a
single reference for reproducing or reasoning about this deployment.

## Overview

`v2` is a fork branch built off upstream `main` with one goal: run OpenClaw in
Docker with the 1Password CLI (`op`) available in the container, published as a
custom image, and started via a customized `docker-compose.yml`.

The image is a **thin wrapper** over the public OpenClaw runtime image. Nothing
is compiled from source; the wrapper just adds the 1Password CLI on top.

---

## 1. Branch and git identity

- Branch: `v2`, based on `origin/main`.
- Local git author identity set for this repo:
  - `user.name = Tom Sekula`
  - `user.email = tom@sekula.com`

## 2. Custom image: thin wrapper with the 1Password CLI

New file: `scripts/docker/op/Dockerfile`

```dockerfile
FROM ghcr.io/openclaw/openclaw:latest
USER root
RUN ... apt install ca-certificates curl gnupg && \
    add 1Password apt key + repo && \
    apt install 1password-cli
USER node
```

- `FROM ghcr.io/openclaw/openclaw:latest` — the public upstream runtime.
- Adds `1password-cli` via 1Password's signed apt repository.
- Reverts to the non-root `node` user after install.
- Published to `ghcr.io/tsekula/openclaw:latest`.

This intentionally replaces an earlier attempt to bake the 1Password CLI into
the root `Dockerfile` via a `OPENCLAW_INSTALL_1PASSWORD_CLI` build arg. That
change was reverted — the root `Dockerfile` is identical to upstream `main`.
The thin wrapper is the canonical approach.

## 3. Publish workflow (GHCR)

New file: `.github/workflows/build-op-image.yml`

- Builds `scripts/docker/op/Dockerfile` and pushes to
  `ghcr.io/tsekula/openclaw:latest`.
- Triggers:
  - `push` to branch `v2`, **only** when these paths change:
    - `scripts/docker/op/Dockerfile`
    - `.github/workflows/build-op-image.yml`
  - `workflow_dispatch` (manual).
- A nightly `schedule` cron was removed so the image builds only on relevant
  `v2` changes (or manual dispatch), never on a timer.

## 4. Customized docker-compose.yml

The compose file was customized to:

- Pull the prebuilt image instead of building locally:
  `image: ${OPENCLAW_IMAGE:-ghcr.io/tsekula/openclaw:latest}` (dropped `build: .`).
- Mount `gh_config` → `/home/node/.config/gh` (both gateway and CLI services).
- Mount `op_config` → `/home/node/.config/op` (gateway service).
- Pass through `OP_SERVICE_ACCOUNT_TOKEN`.
- Pass through additional env vars in both gateway and CLI services:
  - `OPENROUTER_API_KEY`
  - `BRAVE_API_KEY`
  - `CLOUDFLARE_API_TOKEN`
  - `CLOUDFLARE_ACCOUNT_ID`
  - `TELEGRAM_BOT_TOKEN`
  - `TELEGRAM_BOT_TOKEN_LIFE_COACH`
  - `TELEGRAM_BOT_TOKEN_VISION`
  - `TELEGRAM_BOT_TOKEN_FAMILY_BOT`
  - `TELEGRAM_BOT_TOKEN_LINUX`

### Reverted experiments (not in v2)

Two larger compose experiments were tried and then reverted to keep things close
to upstream `main`:

- **ProtonVPN gluetun sidecar + browser service:** added a `gluetun` VPN
  sidecar (`network_mode: service:gluetun`), a `openclaw-browser` sandbox
  service, `/var/run/docker.sock` mount + docker group. Fully reverted.
- Associated env vars (`BROWSER_NOVNC_PASSWORD`, `PROTONVPN_WIREGUARD_PRIVATE_KEY`,
  `PROTONVPN_WIREGUARD_ADDRESS`, `VPN_SERVER_COUNTRY`) were part of that experiment
  and are not present in v2.

## 5. CI: only the image workflow runs

The fork inherited ~96 upstream CI workflows that fired on `main` pushes, PRs,
and cron schedules. All but one were disabled (via `gh workflow disable`):

- **Active:** `Build 1Password CLI image` only.
- **Disabled:** all other upstream workflows (`disabled_manually`).

This is reversible with `gh workflow enable <id>`.

## 6. Data / state / migration notes

- Agent memories, skills, sessions, and config live on the host, not in the
  image, bind-mounted into the container:
  - `~/.openclaw` → `/home/node/.openclaw` (state dir)
  - `~/.openclaw/workspace` → `/home/node/.openclaw/workspace` (memories + skills)
- `v1` (the `vanilla` branch image) and `v2` both mount the same host directory,
  so pointing v2 at the same `OPENCLAW_CONFIG_DIR`/`OPENCLAW_WORKSPACE_DIR` shares
  the data with no migration. To move machines: copy `~/.openclaw` + workspace,
  then run `openclaw doctor`.
- Memories are Markdown (`MEMORY.md`, `USER.md`, `memory/*.md`, `DREAMS.md`);
  skills live under `~/.openclaw/skills`, `~/.agents/skills`, and workspace roots.

## 7. Commands used

```bash
# Create and publish the branch
git checkout -b v2 origin/main
git config --local user.name "Tom Sekula"
git config --local user.email "tom@sekula.com"
git push -u origin v2

# Disable all workflows except the image build (per-workflow, reversible)
gh workflow list --all
gh workflow disable <id>   # for each unwanted workflow
gh workflow enable <id>    # to restore
```

## 8. Current image

- `ghcr.io/tsekula/openclaw:latest` — OpenClaw runtime + 1Password CLI.
- Rebuilt on relevant `v2` pushes or manual dispatch via `build-op-image.yml`.
