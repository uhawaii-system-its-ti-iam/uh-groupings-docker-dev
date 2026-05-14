# Table of Contents

<!-- TOC -->
* [Table of Contents](#table-of-contents)
* [Overview](#overview)
  * [Why KV instead of cubbyhole](#why-kv-instead-of-cubbyhole)
  * [Data persistence and reset](#data-persistence-and-reset)
  * [Network access and TLS (development only)](#network-access-and-tls-development-only)
  * [Expected Vault states (Groupings scripts)](#expected-vault-states-groupings-scripts)
  * [Reminder to unseal the vault](#reminder-to-unseal-the-vault)
* [Installation](#installation)
  * [Vault Setup and Startup](#vault-setup-and-startup)
  * [Enable the KV Secrets Engine](#enable-the-kv-secrets-engine)
  * [Store the Grouper API Password](#store-the-grouper-api-password)
    * [Manually](#manually)
    * [Application read policy and token](#application-read-policy-and-token)
    * [With the web UI](#with-the-web-ui)
  * [Migrating from cubbyhole](#migrating-from-cubbyhole)
* [Troubleshooting](#troubleshooting)
  * [version is obsolete](#version-is-obsolete)
  * [vault Error Head](#vault-error-head)
  * [connection refused](#connection-refused)
  * [API cannot read KV secret](#api-cannot-read-kv-secret)
  * [vault needs to be reinitialized](#vault-needs-to-be-reinitialized)
<!-- TOC -->

# Overview

Deploy a docker container on a development localhost environment to run
HashiCorp Vault to contain secrets for a containerized UH Groupings development
instance.

Implement a vault under the developer home directory to persistently store the
Grouper API password used by the UH Groupings API. When the developer attempts
to run the containerized UH Groupings project the vault will supply the
password.

## Why KV instead of cubbyhole

The Groupings API password is stored in the **KV (Key-Value) secrets engine** at
`kv/uhgroupings`, not in cubbyhole.

Cubbyhole is scoped to a single Vault token: only the token that **wrote** a
cubbyhole secret can **read** it. That is awkward for application credentials
when the operator token (UI / CLI) and the application token (local overrides
file) differ, or after token rotation.

KV stores secrets at a shared path. Access is controlled by **policies**, so an
operator can write the secret with a root (or admin) token while the API uses a
separate read-only token in `uh-groupings-api-overrides.properties`.

## Data persistence and reset

Vault file storage lives under your home directory:

- macOS / Linux: `~/.vault/uhgroupings/data`
- Windows: `%USERPROFILE%\.vault\uhgroupings\data`

Running `./build.sh` or `./build.ps1` from this directory creates the data and config folders if needed and **does not** delete existing storage. Secrets, tokens on disk, and initialization therefore survive stopping and restarting the container (you still need to **unseal** after each restart; see below).

To wipe Vault storage and start from a clean slate (destructive—you must run `vault operator init` again and keep new unseal keys and root token):

1. From `uh-groupings-docker-dev/vault/`, run the reset script for your OS and confirm the prompt:
   - macOS / Linux: `chmod +x reset-vault.sh` once if needed, then `./reset-vault.sh`
   - Windows: `./reset-vault.ps1`
2. Start Vault again with `./build.sh` or `./build.ps1`, then initialize and unseal as in [Vault Setup and Startup](#vault-setup-and-startup).

`docker-compose.yml` mounts this path into the container; do not rely on manual `rm` unless you know what you are removing.

## Network access and TLS (development only)

Docker Compose maps Vault to **127.0.0.1:8200** on the host, so it is not exposed on all interfaces. The UI and API remain reachable from your machine at `http://localhost:8200` or `http://127.0.0.1:8200`.

`vault-config.hcl` disables TLS for local development only. This layout is **not** suitable for production; production deployments should use proper TLS and hardening.

## Expected Vault states (Groupings scripts)

Before building Groupings containers, `groupings/build.sh` and `groupings/build.ps1` call `GET http://127.0.0.1:8200/v1/sys/health`. Typical outcomes:

| HTTP status | Meaning (dev) |
|-------------|----------------|
| 200, 429, 472, 473 | Vault is up in a state where deploy can proceed (active, standby, or replication-related roles). |
| 503 | Sealed—unseal before deploying Groupings. |
| 501 | Not initialized—run `vault operator init` (and unseal) first. |

## Reminder to unseal the vault

Each time the vault container is restarted the vault will need to be unsealed.
The unseal key and the root token will be needed:

- http://localhost:8200/ui/vault/unseal

# Installation

Prep environment, start container.

    cd uh-groupings-docker-dev/vault
    chmod +x build.sh (Mac)
    ./build.sh  (Mac)
    ./build.ps1 (Windows)

On macOS or Linux, `docker-compose.yml` uses the `USERPROFILE` variable for bind mounts. If your shell does not set it, run `export USERPROFILE="$HOME"` in that terminal before `./build.sh` so the mount path matches `~/.vault/uhgroupings/`.

## Vault Setup and Startup

- For development only 1 unseal key is required, rather than the usual 2-3.
- The vault needs to be unsealed upon initialization, after a service restart,
or if it has been manually sealed.
- The vault must be unsealed before the UI will be operational.
- The root token is used to configure the vault, enable secret engines, write
secrets, and create policies. The Groupings API should use a dedicated
read-only token when possible (see below).

The following can be executed from within docker desktop.
- navigate to the "containers" menu
- select the stack "hashicorp-vault-docker-image"
- expand it in order to select the image "groupings-vault".
- the "Logs" menu is the default, select the "Exec" menu to access the
container's command prompt enter the following:


    vault operator init -key-shares=1 -key-threshold=1
    vault operator unseal <Unseal_Key>

_Be sure to save the unseal key and root token for later use._

## Enable the KV Secrets Engine

Run once per Vault instance after init and unseal (from the vault container exec
or CLI with `VAULT_ADDR` set):

    vault login
    vault secrets enable -path=kv -version=2 kv

`-version=2` is explicit so the mount is unambiguously KV v2 regardless of the
Vault image's default. The policy and HTTP path below (`kv/data/uhgroupings`,
`/v1/kv/data/uhgroupings`) depend on KV v2's `data/` segment.

If the engine is already enabled at a different version, disable it first
(`vault secrets disable kv`) and re-enable with `-version=2`, then re-write the
secret. If it is already enabled as v2, Vault reports that the path is in use;
that is fine.

## Store the Grouper API Password

Important vault values referenced throughout this README and by the Groupings
API at runtime (the Groupings build scripts call `/v1/sys/health` for readiness;
the values below are consumed by the Spring API and by manual `vault` CLI /
`curl` commands):

- Vault path:   `kv/uhgroupings` (Spring: `vault://kv/uhgroupings`)
- Password key: `grouperClient.webService.password`
- Vault UI:     http://localhost:8200
- Vault URL:    http://localhost:8200/v1/kv/data/uhgroupings

### Manually

(replace `sample_password` with the actual grouper test API password)

    vault login
    vault kv put kv/uhgroupings grouperClient.webService.password=sample_password
    vault kv get kv/uhgroupings

### Application read policy and token

The Groupings API reads the secret using `spring.cloud.vault.token` from the
local overrides file (not committed to git):

`~/.{username}-conf/uh-groupings-api-overrides.properties`

Apply the read policy from this repository (run from the `vault` directory on
the host with the Vault CLI, or paste the HCL when using container exec):

    vault policy write groupings-api-read policies/groupings-api-read.hcl
    vault token create -policy=groupings-api-read -format=json

From container exec without the repo mounted, write the policy inline:

    vault policy write groupings-api-read - <<'EOF'
    path "kv/data/uhgroupings" {
      capabilities = ["read"]
    }
    EOF

Copy the generated token into overrides:

    spring.cloud.vault.token=<token>

For local development only, using the root token in overrides also works if it
can read KV. A dedicated read token is recommended so the API does not need the
same token that wrote the secret.

After **re-init** or using `reset-vault.sh` / `reset-vault.ps1`: obtain a new root
token, re-enable KV, run `vault kv put` again, update overrides with a new
token, and restart the Groupings API container.

### With the web UI

- Navigate to http://localhost:8200/ui/vault/dashboard
- Log in with the root token
- Open **kv** → **uhgroupings** and create or edit the secret
- Use key `grouperClient.webService.password` and the Grouper API password as the
value

## Migrating from cubbyhole

If you previously stored the password under `cubbyhole/uhgroupings`:

1. Unseal Vault and enable KV (see above).
2. While still on the old setup, read the old value if needed:
   `vault read cubbyhole/uhgroupings`
3. Write to KV:
   `vault kv put kv/uhgroupings grouperClient.webService.password=<password>`
4. Create a read token (see policy section) or keep root in overrides.
5. Restart the Groupings stack so compose uses `vault://kv/uhgroupings`.

# Troubleshooting

## version is obsolete

    WARN[0000] .../hashicorp-vault-docker-image/docker-compose.yml: `version` is obsolete

Docker Compose v2 warns that the version setting is obsolete. Remove it from the docker-compose file.

## vault Error Head

    vault Error Head "https://registry-1.docker.io/v2/library/vault/manifests/latest": unauth...

You must have a dockerhub access token in order to download docker images from Docker Hub.

## connection refused

    operator init -key-shares=1 -key-threshold=1
    Get "http://127.0.0.1:8200/v1/sys/seal-status": dial tcp 127.0.0.1:8200: connect: connection refuse

## API cannot read KV secret

- Confirm Vault is unsealed and the secret exists: `vault kv get kv/uhgroupings`
- Confirm overrides contains a valid `spring.cloud.vault.token` with read access
  to `kv/data/uhgroupings` (or use root for local dev)
- If the API still fails, add to overrides or compose environment:
  - `spring.cloud.vault.kv.enabled=true`
  - `spring.cloud.vault.kv.backend=kv`

## vault needs to be reinitialized

This requires starting over.

1) From this directory, run `./reset-vault.sh` (macOS / Linux) or `./reset-vault.ps1` (Windows) to stop the stack and clear persisted data (or remove `~/.vault/uhgroupings/data` yourself if you prefer).
2) Start Vault again with `./build.sh` or `./build.ps1`.
3) Initialize and unseal as in [Vault Setup and Startup](#vault-setup-and-startup).
4) Enable KV v2, write `kv/uhgroupings`, create policy/token, and update overrides as in [Store the Grouper API Password](#store-the-grouper-api-password).
