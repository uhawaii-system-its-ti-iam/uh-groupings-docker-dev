# build.ps1 - deploy groupings containers with hot source code syncing

# Vault access
$SECRET_PATH = "secret/uhgroupings"
$env:VAULT_ADDR = "http://localhost:8200"
$env:VAULT_SECRET_KEY = "grouperClient.webService.password_json"

# Function: validate and set an environment variable with the absolute /src path.
function Set-SrcVar {
    param(
        [string]$varName
    )
    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrEmpty($varValue)) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not $varValue.EndsWith("/src")) {
        Write-Host "Error: The path must end with '/src'. Exiting..."
        exit 1
    } elseif (-not (Test-Path $varValue -PathType Container)) {
        Write-Host "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    }

    Set-Variable -Name $varName -Value $varValue -Scope Global
}

# Function: validate and set an environment variable with the overrides path.
function Set-OverridesVar {
    param(
        [string]$varName
    )
    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrEmpty($varValue)) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path $varValue -PathType Container)) {
        Write-Host "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    }

    Set-Variable -Name $varName -Value $varValue -Scope Global
}

# Function: get the vault secret.
function Set-TokenVar {
    param(
        [string]$varName
    )
    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrEmpty($varValue)) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    }

    Set-Variable -Name $varName -Value $varValue -Scope Global
}

# Function: get the Grouper API password_json data from the vault.
function Set-PasswordJsonVar {
    param(
        [string]$varName
    )
    $passwordJson = Invoke-RestMethod -Headers @{ "X-Vault-Token" = $env:VAULT_TOKEN } -Method Get -Uri "$env:VAULT_ADDR/v1/$SECRET_PATH" -ErrorAction SilentlyContinue

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to communicate with Vault. Exiting..."
        exit 1
    }

    if ([string]::IsNullOrEmpty($passwordJson)) {
        Write-Host "Error: Failed to retrieve data from Vault. Exiting..."
        exit 1
    }

    Set-Variable -Name $varName -Value $passwordJson -Scope Global
}

Write-Host "-------------------------------------------------------------------------"
Write-Host "To hot sync localhost source code changes into the containers, provide"
Write-Host "the paths to your project /src directories. They are required to hot sync"
Write-Host "localhost source code changes into the containers."
Write-Host "-------------------------------------------------------------------------"

# Set GROUPINGS_OVERRIDES directory path.
Write-Host "Provide the absolute path to the overrides file directory:"
Set-OverridesVar "GROUPINGS_OVERRIDES"

# Set GROUPINGS_API_SRC directory path.
Write-Host "Provide the absolute path:"
Set-SrcVar "GROUPINGS_API_SRC"

# Set GROUPINGS_UI_SRC directory path.
Set-SrcVar "GROUPINGS_UI_SRC"

# Set VAULT_TOKEN value.
Write-Host "Provide the vault token for opening the vault:"
Set-TokenVar "VAULT_TOKEN"

# Get and set the Grouper API password_json.
Write-Host "Retrieving Grouper API password from the vault..."
Set-PasswordJsonVar "VAULT_SECRET_JSON"

# Build/rebuild and deploy the images.
Write-Host "Building and deploying the Grouping API container..."
docker-compose up --build -d
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success: Images built, containers deployed"
} else {
    Write-Host "Error: Review the logs"
}

exit 0