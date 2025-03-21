param serviceBus object
param vNet object
param platform object

var pepName = 'pep-${platform.systemPrefix}-sbus-${platform.environment}-${platform.region}-01'
var pepNicName = 'nic-${platform.systemPrefix}-sbus-${platform.environment}-${platform.region}-01'

resource serviceBus_name 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: serviceBus.name
  location: resourceGroup().location
  sku: {
    name: serviceBus.sku
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: false
    zoneRedundant: false
  }
}

resource serviceBus_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' = {
  name: '${serviceBus.name}/RootManageSharedAccessKey'
  location: resourceGroup().location
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
  dependsOn: [
    serviceBus_name
  ]
}

resource pep 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  location: platform.region
  name: pepName
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vNet.name, vNet.privateLink.name)
    }
    customNetworkInterfaceName: pepNicName
    privateLinkServiceConnections: [
      {
        name: pepName
        properties: {
          privateLinkServiceId: serviceBus_name.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
  }
  tags: {}
}
