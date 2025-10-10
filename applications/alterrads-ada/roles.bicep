
@export()
@description('Read and list Azure Storage containers and blobs')
var storageBlobDataReader = resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')

@export()
@description('Read, write, and delete Azure Storage containers and blobs') 
var storageBlobDataContributor = resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
