#!/usr/bin/env bash
set -euo pipefail

REPO="${HOME}/openclaw"
CONFIG_DIR="${HOME}/.openclaw"

# --- openclaw.json ---
SOURCE="${REPO}/openclaw.json"
TARGET="${CONFIG_DIR}/openclaw.json"

if [[ ! -f "${SOURCE}" ]]; then
    echo "Error: Source file not found: ${SOURCE}"
    exit 1
fi

if [[ -f "${TARGET}" ]]; then
    BACKUP="${TARGET}.backup.$(date +%Y%m%d-%H%M%S)"
    echo "Creating backup: ${BACKUP}"
    cp "${TARGET}" "${BACKUP}"
fi

mkdir -p "$(dirname "${TARGET}")"
echo "Copying ${SOURCE} to ${TARGET}"
cp "${SOURCE}" "${TARGET}"


echo "✓ Configuration updated successfully"
