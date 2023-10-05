
az group create -g SeniorFitnessRG -l eastus
az group delete -g SeniorFitnessRG
az group delete -g SeniorFitnessRG --yes
az group delete -g SeniorFitnessRG -y

az deployment group create -g SeniorFitnessRG -f main.bicep
az deployment group create -g SeniorFitnessRG -f main.bicep -params parameters.json

az bicep build --file functions.bicep
az bicep build --file funtions.bicep --stdout

az bicep build-params --file functions.bicep
az bicep build-params --file funtions.bicep --stdout

az bicep decompile
az bicep generate-params
az bicep format

az deployment group what-if -g SeniorFitnessRG -f main.bicep -p prod.bicepparam
az deployment group create -n 'SeniorFitnessRG' -f main.bicep -p prod.bicepparam 
az deployment group create -n 'SeniorFitnessRG' -f main.bicep -o .bicepparam

az vm list-sizes -l eastus -otable
az vm image list --output table

docker run -it --rm -d -p 8080:80 --name web nginx
