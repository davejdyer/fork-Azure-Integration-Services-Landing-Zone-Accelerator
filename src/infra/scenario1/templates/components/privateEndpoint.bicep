param privateEndpointName string
param privateEndpointResource string
param privateEndpointSubnet string
param privateEndpointVNET string
param privateEndpointVNETResourcegroup string
param privateEndpointGroupID string
param privateDnsZoneName string
param privateDnsResourceGroup string
param privateDnsSubscriptionID string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: privateEndpointName
  location: resourceGroup().location
  properties: {
    subnet: {
      id: resourceId(
        privateEndpointVNETResourcegroup,
        'Microsoft.Network/virtualNetworks/subnets',
        privateEndpointVNET,
        privateEndpointSubnet
      )
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateEndpointResource
          groupIds: [
            privateEndpointGroupID
          ]
        }
      }
    ]
  }
}

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  parent: privateEndpoint
  name: 'default'
  location: resourceGroup().location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: resourceId(
            privateDnsSubscriptionID,
            privateDnsResourceGroup,
            'Microsoft.Network/privateDnsZones',
            privateDnsZoneName
          )
        }
      }
    ]
  }
}
