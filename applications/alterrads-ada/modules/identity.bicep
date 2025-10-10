import { locationType, roleAssignmentListType } from '../types.bicep'

param location locationType
param identityName string
param tags object = {}
param storageRoleAssignments roleAssignmentListType = []


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: identityName
  location: location
  tags: tags
}

resource storageAccountResources 'Microsoft.Storage/storageAccounts@2025-01-01' existing = [for (roleAssignment, i) in storageRoleAssignments: {
  name: roleAssignment.resourceName
}]

resource userRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, i) in storageRoleAssignments: {
  name: guid(resourceGroup().id, managedIdentity.id, roleAssignment.roleId)
  scope: storageAccountResources[i]
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleAssignment.roleId
    principalType: 'ServicePrincipal'
  }
}]

output identityId string = managedIdentity.id
output identityType string = managedIdentity.type

output roleAssigmentIds string[] = [for (_, i) in storageRoleAssignments: userRoleAssignments[i].id]
