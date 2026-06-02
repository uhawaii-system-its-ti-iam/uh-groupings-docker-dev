# reset-vault.ps1 - wipe Vault file storage (destructive). Use when you need a fresh init.
# Run from the vault/ directory. Stops the Vault container before removing data.

$env:HOME = $env:USERPROFILE
$vaultDataDir = "$env:HOME\.vault\uhgroupings\data"

Write-Host "Warning: This removes all Vault data under $vaultDataDir (secrets, keys). You must re-init and unseal."
$null = Read-Host "Press Enter to continue, or Ctrl+C to cancel"

Push-Location $PSScriptRoot
try {
    docker-compose down 2>$null
} finally {
    Pop-Location
}

if (Test-Path $vaultDataDir) {
    Get-ChildItem -Path $vaultDataDir -Force | Remove-Item -Recurse -Force
    Write-Host "Success: Vault data directory cleared."
} else {
    Write-Host "Info: no data directory at $vaultDataDir."
}

Write-Host "Start Vault again with ./build.ps1."
