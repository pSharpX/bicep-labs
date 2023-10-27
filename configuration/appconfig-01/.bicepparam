using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_GOAT'
param environment = 'dev'
param provisioner = 'bicep'

param keyValues = [
  {
    name: '${applicationId}_${environment}:config:base-url'
    value: 'your_base_url'
  }
  {
    name: '${applicationId}_${environment}:config:oauth-url'
    value: 'your_oauth_url'
  }
  {
    name: '${applicationId}_${environment}:config:client-id'
    value: 'your_client_id'
  }
]
