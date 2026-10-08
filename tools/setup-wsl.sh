#!/usr/bin/env bash
# Sentinel Browser — WSL2/Ubuntu build-environment bootstrap.
# Run inside WSL:  bash tools/setup-wsl.sh
# After this, `make dir && make bootstrap` work, and bsys6 can cross-build Windows targets.
set -euo pipefail

echo "==> Installing base build dependencies"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    build-essential git git-lfs curl wget python3 python3-dev python3-pip python3-venv \
    make patch patchutils pigz gnupg xz-utils zstd jq file unzip zip \
    gettext-base pkg-config mingw-w64-tools msitools mono-complete \
    libc6-i386 nodejs npm ca-certificates

# ossign (needed only for signed builds; harmless if absent)
if ! apt-cache show ossign >/dev/null 2>&1; then
    echo "==> Adding OSSign repo for ossign"
    curl -qfA "" --proto =https --tlsv1.2 \
        https://vcs.fi/api/packages/OSSign/debian/repository.key \
        | sudo tee /etc/apt/keyrings/forgejo-OSSign.asc >/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/forgejo-OSSign.asc] https://vcs.fi/api/packages/OSSign/debian stable main" \
        | sudo tee /etc/apt/sources.list.d/forgejo.list >/dev/null
    sudo apt-get update || true
    sudo apt-get install -y --no-install-recommends ossign || echo "ossign unavailable; unsigned builds still work"
fi

echo "==> Done. Next: cd to the repo, 'make dir' then 'make bootstrap'"
