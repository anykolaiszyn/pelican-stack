# init.ps1
# Creates a .env file from .env.example if .env does not exist.

$EnvFile = ".env"
$ExampleFile = ".env.example"

if (-not (Test-Path $EnvFile)) {
    if (Test-Path $ExampleFile) {
        Copy-Item $ExampleFile $EnvFile
        Write-Host ".env file created from .env.example. Please review and update as necessary."
    } else {
        Write-Error "Error: .env.example not found. Cannot create .env file."
        exit 1
    }
} else {
    Write-Host ".env file already exists. No action taken."
}

exit 0
