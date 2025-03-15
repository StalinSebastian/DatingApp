# Set script to stop on errors
$ErrorActionPreference = "Stop"

# Initialize variables for AZ commands
. azure/scripts/_variables.ps1

# Print current directory
Write-Host "Current Directory: $(Get-Location)"

# Restore .NET tools
Write-Host "Restoring .NET tools..."
Set-Location API && dotnet tool restore

# Set Database Connection String
$connectionString = "Server=$dbServer,1433;Database=$dbName;User ID=$dbUser;Password=$dbPassword;Encrypt=True;TrustServerCertificate=False;"

# Run EF Core Migrations
Write-Host "Updating database..."
dotnet ef database update --connection "$connectionString"

Write-Host "Database update completed successfully."
