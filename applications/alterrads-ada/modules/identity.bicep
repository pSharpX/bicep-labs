import { locationType, roleAssignmentListType } from '../types.bicep'

param location locationType
param identityName string
param tags object = {}
param storageScopeRoleAssignments roleAssignmentListType = []
param keyVaultScopeRoleAssignments roleAssignmentListType = []
param roleAssignments roleAssignmentListType = []


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: identityName
  location: location
  tags: tags
}

resource userRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, i) in roleAssignments: {
  name: guid(resourceGroup().id, managedIdentity.id, roleAssignment.roleId)
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleAssignment.roleId
    principalType: 'ServicePrincipal'
  }
}]

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

resource keyVaultResources 'Microsoft.KeyVault/vaults@2025-05-01' existing = [for (roleAssignment, i) in keyVaultScopeRoleAssignments: {
  name: roleAssignment.?resourceName!
}]

resource keyVaultScopeUserRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, i) in keyVaultScopeRoleAssignments: {
  name: guid(resourceGroup().id, managedIdentity.id, roleAssignment.roleId)
  scope: keyVaultResources[i]
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: roleAssignment.roleId
    principalType: 'ServicePrincipal'
  }
}]


output identityId string = managedIdentity.id
output identityType string = managedIdentity.type
output roleAssigmentIds string[] = [for (_, i) in roleAssignments: userRoleAssignments[i].id]
output storageScopeRoleAssigmentIds string[] = [for (_, i) in storageScopeRoleAssignments: storageScopeUserRoleAssignments[i].id]
output keyVaultScopeRoleAssigmentIds string[] = [for (_, i) in keyVaultScopeRoleAssignments: keyVaultScopeUserRoleAssignments[i].id]
