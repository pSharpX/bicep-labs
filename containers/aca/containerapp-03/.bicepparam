using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param keyVaultName = 'your_key_vault'
param containerRegistryName = 'your_container_registry'
param registryUsernameSecretName = 'registry-username'
param registryPassSecretName = 'registry-password'
param containerImage = 'nginx:latest'
param containerName = 'my-nginx-app'
