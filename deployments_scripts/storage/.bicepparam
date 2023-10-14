using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_Dynamite'
param environment = 'dev'
param provisioner = 'bicep'
param resourceNamePrefix = applicationId
param fileName = 'install_docker.sh'
param fileContent = loadTextContent('scripts/install_docker.sh')
