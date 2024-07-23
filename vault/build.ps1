# build.ps1 - initialize for running vault.

# Check if HOME environment variable is not set.
if (-not $env:HOME) {
    Write-Host "Error: the HOME environment variable is not set."
    exit 1
}

# Create the necessary directories for vault data and configuration.
$vaultDataPath = Join-Path $env:HOME ".vault/uhgroupings/data"
$vaultConfigPath = Join-Path $env:HOME ".vault/uhgroupings/config"

New-Item -Path $vaultDataPath -ItemType Directory -Force
New-Item -Path $vaultConfigPath -ItemType Directory -Force

# Ensure any previous vault data is removed to ensure a fresh init.
if (Get-ChildItem -Path $vaultDataPath | Measure-Object).Count -gt 0 {
    Write-Host "Info: removed existing vault data to ensure a fresh init."
    Remove-Item -Path (Join-Path $vaultDataPath "*") -Force
}

# Copy the Vault configuration file to the appropriate directory.
Copy-Item -Path "vault-config.hcl" -Destination $vaultConfigPath -Force

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
