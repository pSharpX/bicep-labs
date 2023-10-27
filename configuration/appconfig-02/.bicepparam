using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param configStoreName = 'sfitba3noakpguecyconfig'
param useExistingConfigStore = true

param keyValues = [
  {
    name: '${applicationId}:${environment}:base-url'
    value: 'your_base_url'
  }
  {
    name: '${applicationId}:${environment}:oauth-url'
    value: 'your_oauth_url'
  }
  {
    name: '${applicationId}:${environment}:client-id'
    value: 'your_client_id'
  }
]
