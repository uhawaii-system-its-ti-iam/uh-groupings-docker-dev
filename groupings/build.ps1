# build.ps1 - deploy groupings containers with hot source code syncing

# Vault access
$env:VAULT_URL = "http://localhost:8200/v1/cubbyhole/uhgroupings"
$env:VAULT_SECRET_KEY = "grouperClient.webService.password"

# Function: get the Grouper API password data from the vault.
function Set-PasswordJsonVar {
    param (
        [string]$varName
    )

    Write-Host "Retrieving password from Vault..."

    # Assemble curl command as a string
    $curlCommand = "curl --header `"X-Vault-Token: $env:VAULT_TOKEN`" --header `"Accept: application/json`" --request GET `"$env:VAULT_URL`" --silent --show-error"

    # Execute curl command
    $passwordJson = Invoke-Expression $curlCommand

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to communicate with Vault. Exiting..."
        exit 1
    }
    if ([string]::IsNullOrEmpty($passwordJson)) {
        Write-Host "Error: Failed to retrieve data from Vault. Exiting..."
        exit 1
    }

    $env:$varName = $passwordJson
}

# Function: validate and set an environment variable with the Maven wrapper directory path.
function Set-MvnwVar {
    param (
        [string]$varName
    )

    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrEmpty($varValue)) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path $varValue -PathType Container)) {
        Write-Host "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path "$varValue\mvnw")) {
        Write-Host "Error: The file 'mvnw' does not exist in the directory $varValue. Exiting..."
        exit 1
    }

    $env:$varName = $varValue
}

# Function: validate and set an environment variable with a directory path.
function Set-PathVar {
    param (
        [string]$varName
    )

    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrEmpty($varValue)) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path $varValue -PathType Container)) {
        Write-Host "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    }

    $env:$varName = $varValue
}

# Function: get the vault secret.
function Set-TokenVar {
    param (
        [string]$varName
    )

    $varValue = Read-Host "Enter $varName"

    if ([string]::IsNullOrEmpty($varValue)) {
        Write-Host "Error: vault secret not found, review the README. Exiting..."
        exit 1
    }

    $env:$varName = $varValue
}

Write-Host "-------------------------------------------------------------------------"
Write-Host "To hot sync localhost source code changes into the containers, provide"
Write-Host "the paths to your project directories. They are required to hot sync"
Write-Host "localhost source code changes into the containers."
Write-Host "-------------------------------------------------------------------------"

# Set GROUPINGS_OVERRIDES directory path.
Write-Host "Provide the absolute path to the overrides file directory:"
Set-PathVar -varName "GROUPINGS_OVERRIDES"

# Set GROUPINGS_API_DIR directory path.
Write-Host "Provide the absolute path to the Maven wrapper:"
Set-MvnwVar -varName "GROUPINGS_API_DIR"

# Set GROUPINGS_UI_DIR directory path.
Set-MvnwVar -varName "GROUPINGS_UI_DIR"

# Set VAULT_TOKEN value.
Write-Host "Provide the vault token for opening the vault:"
Set-TokenVar -varName "VAULT_TOKEN"

# Get and set the Grouper API password_json.
Write-Host "Retrieving Grouper API password from the vault..."
Set-PasswordJsonVar -varName "VAULT_SECRET_JSON"

# Build/rebuild and deploy the images.
Write-Host "Building and deploying the Grouping API container..."
docker-compose up --build -d
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success: Images built, containers deployed"
} else {
    Write-Host "Error: Review the logs, review the README, etc"
}

exit 0
