@export()
@description('Custom user-defined type for App Service resource creation')
type appConfigType = {
  @description('The app service name')
  appName: string
  @description('Description of a SKU for a scalable resource')
  skuName: servicePlanSkuType
  @description('Kind of resource for service plan')
  serverKind: servicePlanKindType
  @description('Kind of resource for app service')
  appKind: appServiceKindType
  @description('Determinte if service plan is linux')
  isLinux: bool
  @description('The list of app settings')
  appSettings: appSettingType[]
  @description('Additional custom properties for app service')
  customProperties: customPropertiesType
}

@export()
@description('Custom user-defined type for custom properties of App Service resource')
type customPropertiesType = {
  @description('Runtime only works for linux-based app service')
  runtime: linuxRuntimeType?
  @description('Runtime only works for windows-based app service')
  netFrameworkVersion: netFrameworkVersionType?
  @description('Runtime only works for windows-based app service')
  phpVersion: phpVersionType?
  @description('Runtime only works for windows-based app service')
  javaVersion: javaVersionType?
  @description('Runtime only works for windows-based app service')
  nodeVersion: nodeVersionType?
  @description('Runtime only works for windows-based app service')
  pythonVersion: pythonVersionType?
}

@export()
type appConfigListType = appConfigType[]


/**
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
*/
@export()
@description('Custom user-defined type for App Service Kind')
type appServiceKindType = 'app' | 'app,linux' | 'app,linux,container' | 'hyperV' | 'app,container,windows' | 'app,linux,kubernetes' | 'app,linux,container,kubernetes' | 'functionapp' | 'functionapp,linux' | 'functionapp,linux,container,kubernetes' | 'functionapp,linux,kubernetes'

@export()
@description('Custom user-defined type for Service Plan Kind')
type servicePlanKindType = 'app' | 'app,linux' | 'app,linux,container' | 'hyperV' | 'app,container,windows' | 'app,linux,kubernetes' | 'app,linux,container,kubernetes' | 'functionapp' | 'functionapp,linux' | 'functionapp,linux,container,kubernetes' | 'functionapp,linux,kubernetes'

@export()
@description('Custom user-defined type for Service Plan SKUs')
type servicePlanSkuType = 'F1' | 'D1' | 'B1' | 'B2' | 'B3' | 'S1' | 'S2' | 'S3' | 'P1' | 'P2' | 'P3' | 'I1' | 'I2' | 'I3' | 'P1v2' | 'P2v2' | 'P3v2' | 'PC1' | 'PC2' | 'PC3' | 'PC4' | 'EP1' | 'EP2' | 'EP3' | 'EI1' | 'EI2' | 'EI3' | 'U1' | 'U2' | 'U3' | 'Y1'


type linuxPhpRuntimeType = 'PHP|8.4' | 'PHP|8.3' | 'PHP|8.2' | 'PHP|8.1'
type linuxDotNetCoreRuntimeType = 'DOTNETCORE|10.0' | 'DOTNETCORE|9.0' | 'DOTNETCORE|8.0'
type linuxNodeRuntimeType = 'NODE|22-lts' | 'NODE|20-lts'
type linuxPythonRuntimeType = 'PYTHON|3.13' | 'PYTHON|3.12' | 'PYTHON|3.11' | 'PYTHON|3.10' | 'PYTHON|3.9'

type linuxJavaJDKRuntimeType = 'JAVA|17-java17' | 'JAVA|21-java21' | 'JAVA|11-java11' | 'JAVA|8-jre8'
type linuxJBossRuntimeType = 'JBOSSEAP|8-java21' | 'JBOSSEAP|8-java17' | 'JBOSSEAP|8-java11' | 'JBOSSEAP|7-java17' | 'JBOSSEAP|7-java11' | 'JBOSSEAP|7-java8'
type linuxTomcatRuntimeType = 'TOMCAT|11.0-java21' | 'TOMCAT|11.0-java17' | 'TOMCAT|11.0-java11' | 'TOMCAT|10.1-java21' | 'TOMCAT|10.1-java17' | 'TOMCAT|10.1-java11' | 'TOMCAT|9.0-java21' | 'TOMCAT|9.0-java17' | 'TOMCAT|9.0-java11' | 'TOMCAT|9.0-jre8'
type linuxJavaRuntimeType = linuxJavaJDKRuntimeType | linuxJBossRuntimeType | linuxTomcatRuntimeType

@export()
@description('Custom user-defined type for Linux Runtime')
type linuxRuntimeType = linuxPhpRuntimeType | linuxJavaRuntimeType | linuxNodeRuntimeType | linuxPythonRuntimeType | linuxDotNetCoreRuntimeType

@export()
@description('Custom user-defined type for allowed version for NetFramework runtime')
type netFrameworkVersionType = 'v4.8' | 'v3.5'

@export()
@description('Custom user-defined type for allowed version for Php runtime')
type phpVersionType = '7.4' | '8.0'

@export()
@description('Custom user-defined type for allowed versions of Java runtime')
type javaVersionType = '1.8'| '11' | '17'

@export()
@description('Custom user-defined type for allowed versions of Node runtime')
type nodeVersionType = '16-lts' | '20-lts'

@export()
@description('Custom user-defined type for allowed versions of Python runtime')
type pythonVersionType = '3.9' | '3.11'

@export()
@description('Custom user-defined type for app settings in App Service')
type appSettingType = {
  name: string
  value: string
}
