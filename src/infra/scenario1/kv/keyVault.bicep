param keyVault object
param vNet object
param platform object

var pepName = 'pep-${platform.systemPrefix}-kv-${platform.environment}-${platform.region}-01'
var pepNicName = 'nic-${platform.systemPrefix}-kv-${platform.environment}-${platform.region}-01'

resource keyVault_name 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVault.name
  location: platform.region
  properties: {
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: keyVault.sku
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
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
          privateLinkServiceId: keyVault_name.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
  tags: {}
}
