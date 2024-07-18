# build.ps1 - deploy groupings containers with hot source code syncing

# Vault access
$env:SECRET_PATH = "/v1/secret/data/secret/uhgroupings"
$env:VAULT_ADDR = "http://localhost:8200"
$env:VAULT_SECRET_KEY = "grouperClient.webService.password"

# Function: get the Grouper API password data from the vault.
function Set-PasswordJsonVar {
    param (
        [string]$varName
    )

    Write-Output "Retrieving password from Vault..."
    $passwordJson = Invoke-RestMethod -Uri "$($env:VAULT_ADDR)/$SECRET_PATH" `
                                      -Headers @{"X-Vault-Token" = $env:VAULT_TOKEN} `
                                      -Method Get `
                                      -ErrorAction Stop
    if (!$passwordJson) {
        Write-Error "Error: Failed to retrieve data from Vault. Exiting..."
        exit 1
    }

    $global:$varName = $passwordJson
}

# Function: validate and set an environment variable with the Maven wrapper
#           directory path.
function Set-MvnwVar {
    param (
        [string]$varName
    )

    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrWhiteSpace($varValue)) {
        Write-Error "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path $varValue -PathType Container)) {
        Write-Error "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path "$varValue\mvnw")) {
        Write-Error "Error: The file 'mvnw' does not exist in the directory $varValue. Exiting..."
        exit 1
    }

    $global:$varName = $varValue
}

# Function: validate and set an environment variable with a directory path.
function Set-PathVar {
    param (
        [string]$varName
    )

    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrWhiteSpace($varValue)) {
        Write-Error "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path $varValue -PathType Container)) {
        Write-Error "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    }

    $global:$varName = $varValue
}

# Function: get the vault secret.
function Set-TokenVar {
    param (
        [string]$varName
    )

    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrWhiteSpace($varValue)) {
        Write-Error "Error: vault secret not found, review the README. Exiting..."
        exit 1
    }

    $global:$varName = $varValue
}

Write-Output "-------------------------------------------------------------------------"
Write-Output "To hot sync localhost source code changes into the containers, provide"
Write-Output "the paths to your project directories. They are required to hot sync"
Write-Output "localhost source code changes into the containers."
Write-Output "-------------------------------------------------------------------------"

# Set GROUPINGS_OVERRIDES directory path.
Write-Output "Provide the absolute path to the overrides file directory:"
Set-PathVar -varName "GROUPINGS_OVERRIDES"

# Set GROUPINGS_API_DIR directory path.
Write-Output "Provide the absolute path to the Maven wrapper:"
Set-MvnwVar -varName "GROUPINGS_API_DIR"

# Set GROUPINGS_UI_DIR directory path.
Set-MvnwVar -varName "GROUPINGS_UI_DIR"

# Set VAULT_TOKEN value.
Write-Output "Provide the vault token for opening the vault:"
Set-TokenVar -varName "VAULT_TOKEN"

# Get and set the Grouper API password_json.
Write-Output "Retrieving Grouper API password from the vault..."
Set-PasswordJsonVar -varName "VAULT_SECRET_JSON"

# Build/rebuild and deploy the images.
Write-Output "Building and deploying the Grouping API container..."
docker-compose up --build -d
if ($?) {
    Write-Output "Success: Images built, containers deployed"
} else {
    Write-Error "Error: Review the logs, review the README, etc"
}

exit 0