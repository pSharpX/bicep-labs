## 🚀 Bicep Deployment

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
