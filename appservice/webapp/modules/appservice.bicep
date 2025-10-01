
@minLength(3)
param location string = resourceGroup().location
param tags object = {}

@minLength(1)
@maxLength(34)
@description('Must be 1-34 chars, start with a letter, only contain lowercase letters/numbers/hyphens, and end with a letter/number.')
param resourceName string
param servicePlanId string

param appSettings array =  []
param allowedOrigins array = []

@allowed([
  'app'                                     // Windows Web app
  'app,linux'                               // Linux Web app
  'app,linux,container'                     // Linux Container Web app
  'hyperV'                                  // Windows Container Web App
  'app,container,windows'                   // Windows Container Web App
  'app,linux,kubernetes'                    // Linux Web App on ARC
  'app,linux,container,kubernetes'          // Linux Container Web App on ARC
  'functionapp'                             // Function Code App
  'functionapp,linux'                       // Linux Consumption Function app
  'functionapp,linux,container,kubernetes'  // Function Container App on ARC
  'functionapp,linux,kubernetes'            // Function Code App on ARC
])
param kind string
param isLinux bool = true

// DOCKER|mcr.microsoft.com/appsvc/node:20-lts
@allowed([
  'PHP:8.4'
  'PHP:8.3'
  'PHP:8.2'
  'PHP:8.1'
  'DOTNETCORE:10.0'
  'DOTNETCORE:9.0'
  'DOTNETCORE:8.0'
  'NODE:22-lts'
  'NODE:20-lts'
  'PYTHON:3.13'
  'PYTHON:3.12'
  'PYTHON:3.11'
  'PYTHON:3.10'
  'PYTHON:3.9'
  'JAVA:17-java17'
  'JAVA:21-java21'
  'JAVA:11-java11'
  'JAVA:8-jre8'
  'JBOSSEAP:8-java21'
  'JBOSSEAP:8-java17'
  'JBOSSEAP:8-java11'
  'JBOSSEAP:7-java17'
  'JBOSSEAP:7-java11'
  'JBOSSEAP:7-java8'
  'TOMCAT:11.0-java21'
  'TOMCAT:11.0-java17'
  'TOMCAT:11.0-java11'
  'TOMCAT:10.1-java21'
  'TOMCAT:10.1-java17'
  'TOMCAT:10.1-java11'
  'TOMCAT:9.0-java21'
  'TOMCAT:9.0-java17'
  'TOMCAT:9.0-java11'
  'TOMCAT:9.0-jre8'
])
param runtime string = 'PYTHON:3.12'
param healthCheckPath string = ''

param netFrameworkVersion string = ''
param phpVersion string = ''
param javaVersion string = ''
param nodeVersion string = ''
param pythonVersion string = ''

var linuxKinds array = [ 
  'app,linux'
]

var windowsKinds array = [ 
  'app'
]

var allowedNetFrameworkVersions array = ['v4.8', 'v3.5']
var allowedPhpVersions array = ['7.4', '8.0']
var allowedJavaVersions array = ['1.8', '11', '17']
var allowedNodeVersions array = ['16-lts', '20-lts']
var allowedPythonVersions array = ['3.9', '3.11']


resource defaultLinuxAppService 'Microsoft.Web/sites@2024-11-01' = if (isLinux) {
  name: resourceName
  location: location
  kind: contains(linuxKinds, kind) ? kind: fail('Invalid kind for linux apps')
  properties: {
    serverFarmId: servicePlanId
    siteConfig: {
      linuxFxVersion: contains(linuxKinds, kind) ? runtime: fail('Invalid kind for linux apps')
      appSettings: appSettings
      healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: allowedOrigins
      }
    }
    httpsOnly: true
  }
}

resource defaultWindowsAppService 'Microsoft.Web/sites@2024-11-01' = if (!isLinux) {
  name: resourceName
  location: location
  kind: contains(windowsKinds, kind) ? kind: fail('Invalid kind for windows apps')
  properties: {
    serverFarmId: servicePlanId
    siteConfig: {
      appSettings: appSettings
      healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
      minTlsVersion: '1.2'
      cors: {
        allowedOrigins: allowedOrigins
      }
      ... (contains(windowsKinds, kind) ? {
        netFrameworkVersion: empty(netFrameworkVersion)
          ? null
            :contains(allowedNetFrameworkVersions, netFrameworkVersion) 
              ? netFrameworkVersion
              : fail('Invalid netframework version')
        phpVersion: empty(phpVersion)
          ? null
            :contains(allowedPhpVersions, phpVersion) 
              ? phpVersion
              : fail('Invalid php version')
        javaVersion: empty(javaVersion)
          ? null
            :contains(allowedJavaVersions, javaVersion) 
              ? javaVersion
              : fail('Invalid java version')
        nodeVersion: empty(nodeVersion)
          ? null
            :contains(allowedNodeVersions, nodeVersion) 
              ? nodeVersion
              : fail('Invalid node version')
        pythonVersion: empty(pythonVersion)
          ? null
            :contains(allowedPythonVersions, pythonVersion) 
              ? pythonVersion
              : fail('Invalid python version')
      }: {})
    }
    httpsOnly: true
  }
}

output appServiceId string = isLinux ? defaultLinuxAppService.id : defaultWindowsAppService.id
output appServiceUrl string = isLinux ? defaultLinuxAppService.properties.hostNames[0] : defaultWindowsAppService.properties.hostNames[0]
