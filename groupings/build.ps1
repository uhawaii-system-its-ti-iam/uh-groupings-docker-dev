# build.ps1 - deploy groupings containers with hot source code syncing

# It all begins here. The Build script requests user input in order to populate
# the environment variables and then invokes docker-compose to begin building
# the Vault and Groupings stacks.
#
# The bash file will check ui directory that user provides
# and decide which docker compose file will be used: angular or react
#
# The build process will create the Vault and Groupings images and put them
# into their respective stacks.

# Vault access
$env:VAULT_URL = "http://localhost:8200/ui"
$env:VAULT_SECRET_URL = "http://localhost:8200/v1/cubbyhole/uhgroupings"
$env:VAULT_SECRET_KEY = "grouperClient.webService.password"

# Function: check the Vault status.
function Check-VaultStatus {
    try {
        $response = Invoke-WebRequest -Uri "$env:VAULT_URL" -Method Head -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "Success: the project vault container is running."
        } else {
            Write-Host "Error: the project vault is NOT available. Review the /vault README. Exiting..."
            exit 1
        }
    } catch {
        Write-Host "Error: the project vault is NOT available. Review the /vault README. Exiting..."
        exit 1
    }
}

# Function: validate and set an environment variable with the Maven wrapper
# directory path.
function Set-MvnwVar {
    param (
        [string]$varName
    )
    $varValue = Read-Host "Enter $varName"

    if (-not $varValue) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path $varValue -PathType Container)) {
        Write-Host "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path "$varValue/mvnw" -PathType Leaf)) {
        Write-Host "Error: The file 'mvnw' does not exist in the directory $varValue. Exiting..."
        exit 1
    }

    Set-Item -Path "Env:\$varName" -Value $varValue
}

# Function: validate and set an environment variable with a directory path.
function Set-PathVar {
    param (
        [string]$varName
    )
    $varValue = Read-Host "Enter $varName"

    if (-not $varValue) {
        Write-Host "Error: $varName cannot be blank. Exiting..."
        exit 1
    } elseif (-not (Test-Path -Path $varValue -PathType Container)) {
        Write-Host "Error: The directory $varValue does not exist. Exiting..."
        exit 1
    }

    Set-Item -Path "Env:\$varName" -Value $varValue
}

# Function: Detect UI project type (Spring Boot or Node.js)
function Get-UIProjectType {
    param (
        [string]$uiDir
    )
    
    if ((Test-Path -Path "$uiDir/package.json") -or (Test-Path -Path "$uiDir/package-lock.json")) {
        return "node"
    } elseif (Test-Path -Path "$uiDir/pom.xml") {
        return "spring"
    } else {
        Write-Host "Error: Could not determine UI project type. Neither package.json/package-lock.json nor pom.xml found. Exiting..."
        exit 1
    }
}

Write-Host "-------------------------------------------------------------------------"
Write-Host "The Vault container must be running to deploy the Groupings containers."

Check-VaultStatus

Write-Host "-------------------------------------------------------------------------"
Write-Host "To hot sync localhost source code changes into the containers, provide"
Write-Host "the paths to your project directories. They are required to hot sync"
Write-Host "localhost source code changes into the containers."
Write-Host "-------------------------------------------------------------------------"

# Set GROUPINGS_API_DIR directory path.
Write-Host "Provide the absolute paths to the Maven wrapper directories:"
Set-MvnwVar "GROUPINGS_API_DIR"

# Set GROUPINGS_UI_DIR directory path.
Write-Host "Provide the absolute path to the UI directory:"
Set-PathVar "GROUPINGS_UI_DIR"

# Detect UI project type and use appropriate compose file
$uiType = Get-UIProjectType $env:GROUPINGS_UI_DIR
$composeFile = if ($uiType -eq "node") { "docker-compose-react.yml" } else { "docker-compose-angular.yml" }

# Build/rebuild and deploy the images.
Write-Host "Building and deploying the Grouping API container using $composeFile..."
docker-compose -f $composeFile up --build -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success: Groupings images built, stack and containers deployed"
} else {
    Write-Host "Error: Review the logs, review the README, etc"
}

exit 0