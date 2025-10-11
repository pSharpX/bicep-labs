@export()
@description('Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries')
var contributor = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24')

@export()
@description('Grants full access to manage all resources, including the ability to assign roles in Azure RBAC')
var owner = resourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')

@export()
@description('Read and list Azure Storage containers and blobs')
var storageBlobDataReader = resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')

@export()
@description('Read, write, and delete Azure Storage containers and blobs') 
var storageBlobDataContributor = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

@export()
@description('Pull artifacts from a container registry') 
var acrPull = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

@export()
@description('Push artifacts to or pull artifacts from a container registry') 
var acrPush = resourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')

@export()
@description('Read secret contents. Only works for key vaults that use the "Azure RBAC" permission mode') 
var keyVaultSecretsUser = resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
