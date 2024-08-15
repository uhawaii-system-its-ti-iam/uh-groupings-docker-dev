#!/usr/bin/env pwsh

# build.ps1 - initialize for running vault.

# Check if HOME environment variable is not set and set it to USERPROFILE if necessary.
if (-not $env:HOME) {
    $env:HOME = $env:USERPROFILE
    Write-Host "Info: HOME environment variable was not set. Set it to USERPROFILE: $env:HOME"
}

# Create the necessary directories for vault data and configuration.
$vaultDataDir = "$env:HOME\.vault\uhgroupings\data"
$vaultConfigDir = "$env:HOME\.vault\uhgroupings\config"

New-Item -Path $vaultDataDir -ItemType Directory -Force | Out-Null
New-Item -Path $vaultConfigDir -ItemType Directory -Force | Out-Null

# Ensure any previous vault data is removed to ensure a fresh init.
if (Test-Path "$vaultDataDir\*") {
    Write-Host "Info: removed existing vault data to ensure a fresh init."
    Remove-Item "$vaultDataDir\*" -Force
}

# Copy the Vault configuration file to the appropriate directory.
Copy-Item -Path "vault-config.hcl" -Destination $vaultConfigDir -Force -Verbose

# Start the vault container using Docker Compose.
docker-compose up -d

# Check if vault started successfully.
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success: the vault container has started. See README for more instructions."
} else {
    Write-Host "Error: failed to start the Vault container."
    exit 1
}

exit 0
