import { locationType, roleAssignmentListType } from '../types.bicep'

param location locationType
param identityName string
param tags object = {}
param storageScopeRoleAssignments roleAssignmentListType = []
param roleAssignments roleAssignmentListType = []


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: identityName
  location: location
  tags: tags
}

resource storageAccountResources 'Microsoft.Storage/storageAccounts@2025-01-01' existing = [for (roleAssignment, i) in storageScopeRoleAssignments: {
  name: roleAssignment.?resourceName!
}]

resource storageScopeUserRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, i) in storageScopeRoleAssignments: {
  name: guid(resourceGroup().id, managedIdentity.id, roleAssignment.roleId)
  scope: storageAccountResources[i]
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleAssignment.roleId
    principalType: 'ServicePrincipal'
  }
}]

resource userRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, i) in roleAssignments: {
  name: guid(resourceGroup().id, managedIdentity.id, roleAssignment.roleId)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleAssignment.roleId
    principalType: 'ServicePrincipal'
  }
}]

output identityId string = managedIdentity.id
output identityType string = managedIdentity.type

output storageScopeRoleAssigmentIds string[] = [for (_, i) in storageScopeRoleAssignments: storageScopeUserRoleAssignments[i].id]
output roleAssigmentIds string[] = [for (_, i) in roleAssignments: userRoleAssignments[i].id]
