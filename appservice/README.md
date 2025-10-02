## 🚀 Bicep Deployment

In this labs, you create the deployment stack at the resource group scope. You can also create the deployment stack at the subscription scope or the management group scope. For more information, see [Create deployment stack](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks#create-deployment-stacks)

### Create Deployment Stack

```bash
az group create --name 'demoRg' --location 'eastus'
```

To create a deployment stack at the resource group scope:
```bash
az stack group create --name demoStack --resource-group 'demoRg' --template-file './main.bicep' --action-on-unmanage 'detachAll'  --deny-settings-mode 'none'
```

To create a deployment stack at the subscription scope:
```bash
az stack sub create --name '<deployment-stack-name>' --location '<location>' --template-file '<bicep-file-name>' --deployment-resource-group' <resource-group-name>' --action-on-unmanage 'detachAll' --deny-settings-mode 'none'
```
The `deployment-resource-group` parameter specifies the resource group used to store the managed resources. If you don't specify the parameter, the managed resources are stored in the subscription scope.

```bash
az stack sub create --name 'onebankDefaultDeploymentStack' --location 'eastus' --template-file 'main.bicep' --action-on-unmanage 'deleteAll' --deny-settings-mode 'none' --parameters .bicepparam
```

### Verify the deployment

```bash
az stack group show --resource-group 'demoRg' --name 'demoStack'
```

### Update the deployment stack
To update a deployment stack, you can modify the underlying Bicep file and rerunning the create deployment stack command.

```bash
az stack group create --name 'demoStack' --resource-group 'demoRg' --template-file './main.bicep' --action-on-unmanage 'detachAll' --deny-settings-mode 'none'
```

To update a deployment stack at the subscription scope:
```bash
az stack sub create --name '<deployment-stack-name>' --location '<location>' --template-file '<bicep-file-name>' --deployment-resource-group '<resource-group-name>' --action-on-unmanage 'detachAll' --deny-settings-mode 'none'
```

From the Azure portal, check the properties of the storage account to confirm the change.

Using the same method, you can add a resource to the deployment stack or remove a managed resource from the deployment stack. For more information, see [Add resources to a deployment stack](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks#add-resources-to-deployment-stack) and [Delete managed resources from a deployment stack.](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks#delete-managed-resources-from-deployment-stack)


#### Control detachment and deletion

A detached resource (or unmanaged resource) refers to a resource that the deployment stack doesn't track or manage but still exists within Azure.

To instruct Azure to delete unmanaged resources, update the stack with the create stack command and include the ActionOnUnmanage switch. For more information, see [Create deployment stack](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-stacks?tabs=azure-cli#create-deployment-stacks).

Use the `action-on-unmanage` switch to define what happens to resources that are no longer managed after a stack is updated or deleted. Allowed values are:

- `deleteAll`: Use delete rather than detach for managed resources and resource groups.
- `deleteResources`: Use delete rather than detach for managed resources only.
- `detachAll`: Detach the managed resources and resource groups.

```bash
az stack sub create --name '<deployment-stack-name>' --location '<location>' --template-file '<bicep-file-name>' --action-on-unmanage 'deleteAll' --deny-settings-mode 'none'
```

### Delete the deployment stack
To delete the deployment stack, and the managed resources:
```bash
az stack group delete --name 'demoStack' --resource-group 'demoRg' --action-on-unmanage 'deleteAll'
```

To delete the deployment stack, but retain the managed resources:
```bash
az stack group delete --name 'demoStack' --resource-group 'demoRg' --action-on-unmanage 'detachAll'
```

```bash
az stack sub delete --name '<deployment-stack-name>' --action-on-unmanage '<deleteAll/deleteResources/detachAll>'
az stack sub delete --name 'demoStack' --action-on-unmanage 'deleteAll'
```

The delete command exclusively removes managed resources and managed resource groups. You're still responsible for deleting the resource groups that aren't managed by the deployment stack.



### Subscription-Level Deployment of a Bicep Template
```bash
az deployment sub create --name "<your_deployment_name>" --location eastus --template-file main.bicep --parameters .bicepparam
```

```bash
az deployment sub create -n "<your_deployment_name>" -l eastus -f main.bicep -p .bicepparam
```
- `--name` or `-n` → The deployment name
- `--location` or `-l` → Location (eastus)
- `--template-file` or `-f` → The path to the bicep file
- `--parameters` or `-p` → Supply deployment parameter values

## 🔍 Deployment Preview

### What-If Analysis Subscription Level (Preview changes)
```bash
az deployment sub what-if  -n "<your_deployment_name>" -l eastus -f main.bicep -p .bicepparam
```

```bash
az deployment sub create --what-if -n "<your_deployment_name>" -l eastus -f main.bicep -p .bicepparam
```
