# techdoc-proposal-studio

techdoc-proposal studio is an agentic workflow which helps design and buid technical proposal solutions.

## Subscription-Level Deployment of a Bicep Template
```bash
az deployment sub create --name "<your_subscription_name>" --location eastus --template-file main.bicep --parameters .bicepparam
```


### Deploy techdoc-proposal-studio


```bash
az login

az deployment sub create --name techdoc-proposal-deploy  --location westus3 --template-file main.bicep --parameters .bicepparam
```