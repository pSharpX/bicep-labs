
targetScope = 'subscription'

@minLength(3)
@maxLength(24)
@description('Must contains alpanumric chararacters and dash')
param resourceName string

@allowed([
  'eastus'
  'westeurope'
  'centralus'
])
param location string = 'eastus'

@allowed([ 'dev', 'test', 'stagging', 'prod'])
param environment string = 'dev'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param applicationId string = 'onebank'

@allowed([
  'bicep'
  'terraform'
  'pulumi'
  'arm'
])
param provisioner string = 'bicep'

@minLength(3)
@maxLength(20)
@description('It represents the owner of the application. Must contains alpanumric chararacters and dash')
param owner string = 'TeamDragons'

var tags = {
  application: applicationId
  environment: environment
  owner: owner
  provisioner: provisioner
}

resource onebankRG 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceName
  location: location
  tags: tags
}

output resourceGroupId string = onebankRG.id
