using 'main.bicep'

param applicationId = 'sfit'
param owner = 'Team_Dynamite'
param environment = 'dev'
param provisioner = 'bicep'

param storageAccountName = 'sfitvbjilulkpspswsa'
param containerName = 'installation-scripts'
param storageAccountResourceGroup = 'DevOps_rg'
param files = [
  {
    upload: false
    fileName: 'install_docker.sh'
    fileContent: loadTextContent('configs/install_docker.sh')
  }
  {
    upload: false
    fileName: 'install_nginx.sh'
    fileContent: loadTextContent('configs/install_nginx.sh')
  }
  {
    upload: false
    fileName: 'install_postgresql.sh'
    fileContent: loadTextContent('configs/install_postgresql.sh')
  }
  {
    upload: false
    fileName: 'install_mysql.sh'
    fileContent: loadTextContent('configs/install_mysql.sh')
  }
  {
    upload: false
    fileName: 'install_mssql.sh'
    fileContent: loadTextContent('configs/install_mssql.sh')
  }
  {
    upload: true
    fileName: 'text.txt'
    fileContent: loadTextContent('configs/text.txt')
  }
]
