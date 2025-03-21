@description('System prefix used in naming resources')
param systemPrefix string = 'ais'

@description('Type of environment')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev'

@description('CIDR prefix for the VNet address space.')
param vnetAddressSpace string = '192.168.0.0/16'

@description('CIDR address prefix for the front end subnet.')
param frontEndSubnet string = '192.168.1.0/24'

@description('CIDR address prefix for the back end subnet.')
param backEndSubnet string = '192.168.2.0/24'

@description('CIDR address prefix for the private link.')
param privateLinkSubnet string = '192.168.10.0/24'

@description('CIDR address prefix for the IaaS VM\'s.')
param VMSubnet string = '192.168.20.0/24'

@description('API Mangement Administrator Email')
param apimAdminEmail string = 'admin@domain.com'

@description('API Mangement Organsiation Name')
param apimOrganisation string = 'Organisation'

var srcUri = deployment().properties.templateLink.uri
var platform = {
  systemPrefix: systemPrefix
  environment: environment
  region: resourceGroup().location
}
var nameSuffix = '-${systemPrefix}-${environment}-${platform.region}-01'
var storage = {
  name: 'stg${platform.systemPrefix}${platform.environment}${uniqueString(resourceGroup().id)}'
}
var logicApp = {
  name: 'logic${nameSuffix}'
}
var funcApp = {
  name: 'func${nameSuffix}'
}
var dataFactory = {
  name: 'df${nameSuffix}'
}
var keyVault = {
  name: 'kv${platform.systemPrefix}${platform.environment}${uniqueString(resourceGroup().id)}'
  sku: 'Standard'
}
var logAnalytics = {
  name: 'log${nameSuffix}'
}
var appInsights = {
  name: 'appi${nameSuffix}'
}
var apim = {
  name: 'apim${nameSuffix}'
  tier: 'Developer'
  capacity: '1'
  identity: 'None'
  adminEmail: apimAdminEmail
  organisation: apimOrganisation
}
var serviceBus = {
  name: 'sbus${nameSuffix}'
  sku: 'Premium'
}
var vNet = {
  name: 'vnet${nameSuffix}'
  address: vnetAddressSpace
  frontEnd: {
    name: 'snet-${systemPrefix}-frontend-${environment}-${platform.region}-01'
    nsg: 'nsg-${systemPrefix}-frontend-${environment}-${platform.region}-01'
    address: frontEndSubnet
  }
  backEnd: {
    name: 'snet-${systemPrefix}-backend-${environment}-${platform.region}-01'
    nsg: 'nsg-${systemPrefix}-backend-${environment}-${platform.region}-01'
    address: backEndSubnet
  }
  privateLink: {
    name: 'snet-${systemPrefix}-privatelink-${environment}-${platform.region}-01'
    address: privateLinkSubnet
  }
  VM: {
    name: 'snet-${systemPrefix}-vm-${environment}-${platform.region}-01'
    address: VMSubnet
  }
}

module caf_ais_keyvault 'kv/keyVault.json' = {
  name: 'caf-ais-keyvault'
  params: {
    platform: platform
    vNet: vNet
    keyVault: keyVault
  }
  dependsOn: [
    caf_ais_vnet
  ]
}

module caf_ais_vnet 'vnet/vNet.json' = {
  name: 'caf-ais-vnet'
  params: {
    vNet: vNet
  }
}

module caf_ais_servicebus 'sbus/serviceBus.json' = {
  name: 'caf-ais-servicebus'
  params: {
    platform: platform
    vNet: vNet
    serviceBus: serviceBus
  }
  dependsOn: [
    caf_ais_vnet
  ]
}

module caf_ais_logicapp 'la/logicApp.json' = {
  name: 'caf-ais-logicapp'
  params: {
    platform: platform
    vNet: vNet
    storage: storage
    logicApp: logicApp
    appInsights: appInsights
  }
  dependsOn: [
    caf_ais_vnet
    caf_ais_app_insights
  ]
}

module caf_ais_funcapp 'func/funcApp.json' = {
  name: 'caf-ais-funcapp'
  params: {
    platform: platform
    vNet: vNet
    storage: storage
    funcApp: funcApp
    appInsights: appInsights
  }
  dependsOn: [
    caf_ais_vnet
    caf_ais_app_insights
    caf_ais_logicapp
  ]
}

module caf_ais_dataFactory 'df/dataFactory.json' = {
  name: 'caf-ais-dataFactory'
  params: {
    platform: platform
    vNet: vNet
    storage: storage
    dataFactory: dataFactory
    appInsights: appInsights
  }
  dependsOn: [
    caf_ais_vnet
    caf_ais_app_insights
  ]
}

module caf_ais_apim 'apim/template.json' = {
  name: 'caf-ais-apim'
  params: {
    platform: platform
    vNet: vNet
    apim: apim
  }
  dependsOn: [
    caf_ais_vnet
  ]
}

module caf_ais_log_analytics 'log/logAnalytics.json' = {
  name: 'caf-ais-log-analytics'
  params: {
    platform: platform
    vNet: vNet
    logAnalytics: logAnalytics
  }
}

module caf_ais_app_insights 'log/appInsights.json' = {
  name: 'caf-ais-app-insights'
  params: {
    platform: platform
    vNet: vNet
    appInsights: appInsights
    logAnalytics: logAnalytics
  }
  dependsOn: [
    caf_ais_log_analytics
  ]
}
