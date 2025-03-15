export const environment = {
  production: process.env['PRODUCTION_MODE'] ?? true,
  serviceApiEndpoint: process.env['SERVICE_API_ENDPOINT'] ?? 'https://datingapp-api.azurewebsites.net/api/'
};
