param vNet object
param platform object
param storage object
param dataFactory object
param appInsights object

resource dataFactory_name 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactory.name
  location: platform.region
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource pep_platform_systemPrefix_df_platform_environment_platform_region_01 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: platform.region
  name: 'pep-${platform.systemPrefix}-df-${platform.environment}-${platform.region}-01'
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNet.name, vNet.privateLink.name)
    }
    customNetworkInterfaceName: 'nic-${platform.systemPrefix}-df-${platform.environment}-${platform.region}-01'
    privateLinkServiceConnections: [
      {
        name: 'pep-${platform.systemPrefix}-df-${platform.environment}-${platform.region}-01'
        properties: {
          privateLinkServiceId: dataFactory_name.id
          groupIds: [
            'dataFactory'
          ]
        }
      }
    ]
  }
  tags: {}
}

resource privatelink_datafactory_azure_net 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: string('privatelink.datafactory.azure.net')
  location: 'global'
  tags: {}
  properties: {}
  dependsOn: [
    pep_platform_systemPrefix_df_platform_environment_platform_region_01
  ]
}
