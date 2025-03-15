# PowerShell Script to Deploy Dating App to Azure

# Initialize variables for AZ commands
. azure/scripts/_variables.ps1

# Use the imported variables
Write-Host "Deploying to resource group: $acrResourceGroup"

# Step 1: Create Resource Group for ACR container images
az group create --name $acrResourceGroup --location "Southeast Asia"

# Step 2: Create and Configure Azure Container Registry (ACR)
Write-Host "Creating Azure Container Registry..."
az acr create --name "$acrName" --resource-group $acrResourceGroup --sku Basic --admin-enabled true
az acr login --name $acrName

# Step 3: Build and Push Docker Images
Write-Host "Building and Pushing API Docker Image..."
Write-Host "Current Directory: $(Get-Location)"
Push-Location $PSScriptRoot\..\..\
Write-Host "Switching to: $(Get-Location)"

docker build -t "$acrName.azurecr.io/api:latest" -f "docker/build/api/Dockerfile" .
docker push "$acrName.azurecr.io/api:latest"

Write-Host "Building and Pushing Frontend Docker Image..."
docker build -t "$acrName.azurecr.io/app:latest" -f "docker/build/app/Dockerfile" .
docker push "$acrName.azurecr.io/app:latest"

Pop-Location  # Return to the previous working directory

# Step 4: Verify ACR Repositories
Write-Host "Listing ACR Repositories..."
az acr repository list --name $acrName --output table