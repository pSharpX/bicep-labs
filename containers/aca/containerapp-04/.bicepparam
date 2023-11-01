using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param keyVaultName = 'your_keyvault_name'
param containerRegistryName = 'your_registry_name'
param registryUsernameSecretName = 'registry-username'
param registryPassSecretName = 'registry-password'
param containerImage = 'nginx:latest'
param containerName = 'my-nginx-app'
param configStoreName = 'your_appconfig_name'
