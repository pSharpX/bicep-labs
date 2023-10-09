
az group create -g SeniorFitness_rg -l eastus
az group delete -g SeniorFitness_rg
az group delete -g SeniorFitness_rg --yes
az group delete -g SeniorFitness_rg -y

az deployment group create -g SeniorFitness_rg -f main.bicep
az deployment group create -g SeniorFitness_rg -f main.bicep -params parameters.json

az bicep build --file functions.bicep
az bicep build --file funtions.bicep --stdout

az bicep build-params --file functions.bicep
az bicep build-params --file funtions.bicep --stdout

az bicep decompile
az bicep generate-params
az bicep format

az deployment group what-if -g SeniorFitness_rg -f main.bicep -p prod.bicepparam
az deployment group create -n 'SeniorFitness_rg' -f main.bicep -p prod.bicepparam 
az deployment group create -n 'SeniorFitness_rg' -f main.bicep -o .bicepparam

az vm list-sizes -l eastus -otable
az vm image list --output table

docker run -it --rm -d -p 8080:80 --name web nginx
