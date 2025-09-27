# Azure Bicep Labs

This README provides a quick reference for managing Azure resources and deployments using **Azure CLI** with **Bicep**, along with some related Docker commands for testing.  

---
## 📦 Resource Group Management

### Create a Resource Group  
```bash
az group create -g SeniorFitness_rg -l eastus
```

- `-g → Resource group name (SeniorFitness_rg)`
- `-l → Location (eastus)`

### Delete a Resource Group
```bash
az group delete -g SeniorFitness_rg
```

With confirmation prompt:
```bash
az group delete -g SeniorFitness_rg --yes
az group delete -g SeniorFitness_rg -y
```
Both `--yes` and `-y` bypass the confirmation prompt.

## 🚀 Bicep Deployment

### Deploy a Bicep Template
```bash
az deployment group create -g SeniorFitness_rg -f main.bicep
```

With parameters file:
```bash
az deployment group create -g SeniorFitness_rg -f main.bicep -p parameters.json
```

### Subscription-Level Deployment of a Bicep Template
```bash
az deployment sub create --name "<your_subscription_name>" --location eastus --template-file main.bicep --parameters .bicepparam
```
```bash
az deployment sub create -n "<your_subscription_name>" -l eastus -f main.bicep -p .bicepparam
```
- `--name` or `-n` → The deployment name
- `--location` or `-l` → Location (eastus)
- `--template-file` or `-f` → The path to the bicep file
- `--parameters` or `-p` → Supply deployment parameter values

## 🔧 Bicep Build & Compile
Build a `.bicep` File → JSON ARM Template
```bash
az bicep build --file functions.bicep
```
Output directly to terminal:
```bash
az bicep build --file functions.bicep --stdout
```

## 📝 Bicep Parameters

### Generate Parameters File from Bicep
```bash
az bicep build-params --file functions.bicep
```

Print to stdout:
```bash
az bicep build-params --file functions.bicep --stdout
```

## 🔄 Other Useful Bicep Commands

### Decompile ARM → Bicep
```bash
az bicep decompile
```

### Generate default .bicepparam file
```bash
az bicep generate-params
```

### Format Bicep code
```bash
az bicep format
```

## 🔍 Deployment Preview


### What-If Analysis (Preview changes)
```bash
az deployment group what-if -g SeniorFitness_rg -f main.bicep -p prod.bicepparam
```
### What-If Analysis Subscription Level (Preview changes)
```bash
az deployment sub what-if  -n "<your_subscription_name>" -l eastus -f main.bicep -p .bicepparam
```

```bash
az deployment sub create --what-if -n "<your_subscription_name>" -l eastus -f main.bicep -p .bicepparam
```

### Deployment with Parameters
```bash
az deployment group create -n SeniorFitness_rg -f main.bicep -p prod.bicepparam
```

### Output to .bicepparam file
```bash
az deployment group create -n SeniorFitness_rg -f main.bicep -o .bicepparam
```

## 💻 VM Reference

### List available VM sizes:
```bash
az vm list-sizes -l eastus -o table
```

### List available VM images:
```bash
az vm image list --output table
```

## 🐳 Docker Quick Test

### Run an Nginx container:
```bash
docker run -it --rm -d -p 8080:80 --name web nginx
```
- `-it` → interactive terminal
- `--rm` → auto remove when stopped
- `-d` → run in background (detached)
- `-p 8080:80` → map host port 8080 → container port 80
- `--name web` → container name

## Usefull resources
- [What is Bicep?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
- [What is infrastructure as code (IaC)?](https://learn.microsoft.com/en-us/devops/deliver/what-is-infrastructure-as-code)
- [Bicep](https://github.com/Azure/bicep)

This document serves as a command reference for managing resource groups and deploying resources with Azure Bicep.
