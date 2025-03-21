param vNet object
param platform object
param storage object
param funcApp object
param appInsights object

var hostingPlanName = 'plan-${platform.systemPrefix}-func-${platform.environment}-${platform.region}-01'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: resourceGroup().location
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    family: 'EP'
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 20
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource funcApp_name 'Microsoft.Web/sites@2021-02-01' = {
  name: funcApp.name
  location: resourceGroup().location
  kind: 'functionapp'
  properties: {
    reserved: false
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(resourceId('microsoft.insights/components', appInsights.name), '2015-05-01').InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts',storage.name),'2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts',storage.name),'2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(funcApp.name)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

resource pep_platform_systemPrefix_func_platform_environment_platform_region_01 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: platform.region
  name: 'pep-${platform.systemPrefix}-func-${platform.environment}-${platform.region}-01'
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNet.name, vNet.privateLink.name)
    }
    customNetworkInterfaceName: 'nic-${platform.systemPrefix}-func-${platform.environment}-${platform.region}-01'
    privateLinkServiceConnections: [
      {
        name: 'pep-${platform.systemPrefix}-func-${platform.environment}-${platform.region}-01'
        properties: {
          privateLinkServiceId: funcApp_name.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
  tags: {}
}

resource privatelink_azurewebsites_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: string('privatelink.azurewebsites.net')
  location: 'global'
  tags: {}
  properties: {}
  dependsOn: [
    pep_platform_systemPrefix_func_platform_environment_platform_region_01
  ]
}
