# PowerShell Script to Deploy Dating App to Azure

##Allow execution if necessary (only required once):
# ```
#Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# ```

# Initialize variables for AZ commands
. azure/scripts/_variables.ps1

# Use the imported variables
Write-Host "Deploying to resource group: $resourceGroup"

# Step 1: Create Resource Group for ACR container images
az group create --name $resourceGroup --location "Southeast Asia"

# Step 2: Create a SQL Server Instance
az sql server create  --name $dbServerName --resource-group $resourceGroup `
                      --location "$location" `
                      --admin-user "$dbUser" `
                      --admin-password "$dbPassword"

# Configure Firewall Rule (Allow all Azure services)
az sql server firewall-rule create --name AllowAzureServices --resource-group $resourceGroup `
                                   --server $dbServerName `
                                   --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

$clientIP = (Invoke-WebRequest -Uri "https://ifconfig.me/ip").Content

az sql server firewall-rule create --name AllowClientIP --resource-group $resourceGroup `
                                   --server $dbServerName `
                                   --start-ip-address $clientIP `
                                   --end-ip-address $clientIP


az sql db create --name $dbName --resource-group $resourceGroup `
                 --server $dbServerName `
                 --edition GeneralPurpose `
                 --service-objective GP_S_Gen5_2 `
                 --max-size 32GB `
                 --zone-redundant false `
                 --collation SQL_Latin1_General_CP1_CI_AS `
                 --backup-storage-redundancy Local

# Enable Transparent Data Encryption (TDE)
az sql db tde set --resource-group $resourceGroup --server $dbServerName --database $dbName --status Enabled

# Step 3: Create App Service Plan
Write-Host "Creating Azure App Service Plan..."
az appservice plan create --name $servicePlan --resource-group $resourceGroup `
                          --location "$location" `
                          --sku B1 --is-linux

# Step 4: Deploy API Web App
Write-Host "Deploying API Web App..."
az webapp create --name $apiApp --plan $servicePlan --resource-group $resourceGroup `
                 --deployment-container-image-name "$acrName.azurecr.io/api:latest"

# Step 5: Configure API Web App Container
Write-Host "Configuring API Web App..."
$acrUsername = az acr credential show --name $acrName --query username --output tsv
$acrPassword = az acr credential show --name $acrName --query passwords[0].value --output tsv

az webapp config container set --name $apiApp --resource-group $resourceGroup `
                                --container-image-name "$acrName.azurecr.io/api:latest" `
                                --container-registry-url "https://$acrName.azurecr.io" `
                                --container-registry-user $acrUsername `
                                --container-registry-password $acrPassword

# Step 6: Assign Managed Identity and Grant Permissions
Write-Host "Assigning Managed Identity to API..."
$apiIdentity = az webapp identity assign --name $apiApp --resource-group $resourceGroup `
                                          --query principalId --output tsv
$acrId = az acr show --name $acrName --resource-group $acrResourceGroup --query id --output tsv

az role assignment create --assignee $apiIdentity --role AcrPull --scope $acrId

# Step 7: Enable Managed Identity Authentication
Write-Host "Enabling Managed Identity Authentication..."
az webapp config container set --name $apiApp --resource-group $resourceGroup `
                                --docker-custom-image-name "$acrName.azurecr.io/api:latest" `
                                --docker-registry-server-url "https://$acrName.azurecr.io"

# Step 8: Set API App Settings
Write-Host "Setting API Web App Configuration..."
$hash = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 70 | ForEach-Object { [char]$_ })

az webapp config appsettings set --name $apiApp --resource-group $resourceGroup `
                                  --settings ASPNETCORE_ENVIRONMENT=Production
az webapp config appsettings set --name $apiApp --resource-group $resourceGroup `
                                  --settings WEBSITES_PORT=80
az webapp config appsettings set --name $apiApp --resource-group $resourceGroup `
                                  --settings TokenKey="$hash"
az webapp config appsettings set --name $apiApp --resource-group $resourceGroup `
                                  --settings AllowedHosts="*"
az webapp config appsettings set --name $apiApp --resource-group $resourceGroup `
                                  --settings Logging__LogLevel__Default=Information
az webapp config appsettings set --name $apiApp --resource-group $resourceGroup `
                                  --settings Logging__LogLevel__Microsoft.AspNetCore=Information

# Step 9: Configure Database Connection String
Write-Host "Configuring Database Connection..."
az webapp config connection-string set --name $apiApp --resource-group $resourceGroup `
  --connection-string-type SQLSERVER `
  --settings DefaultConnection="Server=$dbServer,1433;Database=$dbName;User ID=$dbUser;Password=$dbPassword;Encrypt=True;TrustServerCertificate=False;"

# Step 10: Add CORS for the frontend
az webapp cors add --name $apiApp --resource-group $resourceGroup `
                    --allowed-origins https://$frontendApp.azurewebsites.net

# Step 11: Enable Logging for API
Write-Host "Enabling Logging for API..."
az webapp log config --name $apiApp --resource-group $resourceGroup `
                      --docker-container-logging filesystem

# Step 12: Deploy Frontend Web App
Write-Host "Deploying Frontend Web App..."
az webapp create --name $frontendApp --plan $servicePlan --resource-group $resourceGroup `
                  --deployment-container-image-name "$acrName.azurecr.io/app:latest"

# Step 13: Set Frontend App Settings
Write-Host "Setting Frontend Web App Configuration..."
az webapp config appsettings set --name $frontendApp --resource-group $resourceGroup `
                                  --settings SERVICE_API_ENDPOINT="https://$apiApp.azurewebsites.net/api/"
az webapp config appsettings set --name $frontendApp --resource-group $resourceGroup `
                                  --settings PRODUCTION_MODE=true

# Step 14: Monitor Application Logs (Optional)
Write-Host "To monitor API logs, run: az webapp log tail --name $apiApp --resource-group $resourceGroup"
Write-Host "To monitor Frontend logs, run: az webapp log tail --name $frontendApp --resource-group $resourceGroup"

Write-Host "Deployment completed successfully!"

# Step 15: Cleanup (Optional)
# Write-Host "Deleting Resource Group..."
# az group delete --name $resourceGroup --yes --no-wait