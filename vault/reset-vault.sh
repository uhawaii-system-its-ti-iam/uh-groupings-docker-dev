#!/bin/sh
# reset-vault.sh - wipe Vault file storage (destructive). Use when you need a fresh init.
# Run from the vault/ directory. Stops the Vault container before removing data.

set -e

if [ -z "${HOME}" ]; then
  echo "Error: the HOME environment variable is not set."
  exit 1
fi

VAULT_DATA="${HOME}/.vault/uhgroupings/data"

echo "Warning: This removes all Vault data under ${VAULT_DATA} (secrets, keys). You must re-init and unseal."
echo "Press Ctrl+C to cancel, or Enter to continue."
read -r _

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

docker-compose down 2>/dev/null || true

if [ -d "${VAULT_DATA}" ]; then
  for f in "${VAULT_DATA}"/*; do
    [ -e "$f" ] || continue
    rm -rf "$f"
  done
  echo "Success: Vault data directory cleared."
else
  echo "Info: no data directory at ${VAULT_DATA}."
fi

echo "Start Vault again with ./build.sh (or build.ps1 on Windows)."
