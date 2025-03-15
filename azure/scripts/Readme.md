# Azure Deployment Guide for Dating App

This guide outlines the step-by-step process to deploy a **Dating App** using **Azure Container Registry (ACR)** and **Azure Web App for Containers**.

---

## 1. Create Resource Group

```sh
az group create --name DatingAppResourceGroup --location "Southeast Asia"
```

---

## 2. Create and Configure Azure Container Registry (ACR)

### Create ACR
```sh
az acr create --resource-group DatingAppResourceGroup --name acrsimpledatingapp --sku Basic --admin-enabled true
```

### Login to ACR
```sh
az acr login --name acrsimpledatingapp
```

### Build and Push Docker Images
```sh
docker build -t acrsimpledatingapp.azurecr.io/api:latest -f ./docker/build/api/Dockerfile .
docker push acrsimpledatingapp.azurecr.io/api:latest

docker build -t acrsimpledatingapp.azurecr.io/app:latest -f ./docker/build/app/Dockerfile .
docker push acrsimpledatingapp.azurecr.io/app:latest
```

### Verify ACR Repositories
```sh
az acr repository list --name acrsimpledatingapp --output table
```

---

## 3. Create App Service Plan

```sh
az appservice plan create --name DatingAppServivePlan --resource-group DatingAppResourceGroup --location "Southeast Asia" --sku B1 --is-linux
```

---

## 4. Deploy API Web App

### Create API Web App
```sh
az webapp create --name datingapp-api --plan DatingAppServivePlan --resource-group DatingAppResourceGroup --deployment-container-image-name acrsimpledatingapp.azurecr.io/api:latest
```

### Configure API Web App Container
```sh
az webapp config container set --name datingapp-api --resource-group DatingAppResourceGroup \
  --docker-custom-image-name acrsimpledatingapp.azurecr.io/api:latest \
  --docker-registry-server-url https://acrsimpledatingapp.azurecr.io \
  --docker-registry-server-user $(az acr credential show --name acrsimpledatingapp --query username --output tsv) \
  --docker-registry-server-password $(az acr credential show --name acrsimpledatingapp --query passwords[0].value --output tsv)
```

### Assign Managed Identity and Grant Permissions
```sh
az webapp identity assign --name datingapp-api --resource-group DatingAppResourceGroup
az role assignment create --assignee $(az webapp identity show --name datingapp-api --resource-group DatingAppResourceGroup --query principalId --output tsv) \
  --role AcrPull --scope $(az acr show --name acrsimpledatingapp --resource-group DatingAppResourceGroup --query id --output tsv)
```

### Enable Managed Identity Authentication
```sh
az webapp config set --name datingapp-api --resource-group DatingAppResourceGroup --acr-use-managed-identity-credentials true
```

### Set API App Settings
```sh
az webapp config appsettings set --name datingapp-api --resource-group DatingAppResourceGroup --settings ASPNETCORE_ENVIRONMENT=Production
az webapp config appsettings set --name datingapp-api --resource-group DatingAppResourceGroup --settings WEBSITES_PORT=80
az webapp config appsettings set --name datingapp-api --resource-group DatingAppResourceGroup --settings TokenKey=a3f1d9e2b8c7f6543a1b9d8c7e6f5a4b3c2d1e0f9b8a7c6d5e4f3a2b1c0d9e8f
az webapp config appsettings set --name datingapp-api --resource-group DatingAppResourceGroup --settings AllowedHosts=*
az webapp config appsettings set --name datingapp-api --resource-group DatingAppResourceGroup --settings Logging__LogLevel__Default=Debug
az webapp config appsettings set --name datingapp-api --resource-group DatingAppResourceGroup --settings Logging__LogLevel__Microsoft.AspNetCore=Debug
```

### Configure Database Connection String
```sh
az webapp config connection-strings set --name datingapp-api --resource-group DatingAppResourceGroup \
  --connection-string-type SQLSERVER \
  --settings DefaultConnection="Server=simple-dating-app.database.windows.net,1433;Database=DatingDB;User ID=adminuser;Password=Password@1;Encrypt=True;TrustServerCertificate=False;"
```

### Enable Logging for API
```sh
az webapp log config --name datingapp-api --resource-group DatingAppResourceGroup --docker-container-logging filesystem
```

---

## 5. Deploy Frontend Web App

### Create Frontend Web App
```sh
az webapp create --name datingapp-frontend --plan DatingAppServivePlan --resource-group DatingAppResourceGroup --deployment-container-image-name acrsimpledatingapp.azurecr.io/app:latest
```

### Set Frontend App Settings
```sh
az webapp config appsettings set --name datingapp-frontend --resource-group DatingAppResourceGroup --settings SERVICE_API_ENDPOINT="https://datingapp-api.azurewebsites.net/api/"
az webapp config appsettings set --name datingapp-frontend --resource-group DatingAppResourceGroup --settings PRODUCTION_MODE=true
```

---

## 6. Monitor Application Logs

### Tail API Logs
```sh
az webapp log tail --name datingapp-api --resource-group DatingAppResourceGroup
```

### Tail Frontend Logs
```sh
az webapp log tail --name datingapp-frontend --resource-group DatingAppResourceGroup
```

---

## 7. Delete the Resource Group (Cleanup)

```sh
az group delete --name DatingAppResourceGroup --yes --no-wait
```

---

## Conclusion
This guide provides a structured approach to deploy a **Dating App** using Azure services. The application consists of:
- **Backend API** hosted as an Azure Web App.
- **Frontend App** hosted as an Azure Web App.
- **Azure Container Registry (ACR)** for containerized deployment.
- **App Service Plan** for hosting both applications.

Ensure proper security measures are in place before deploying to production, such as storing sensitive credentials in **Azure Key Vault**.

