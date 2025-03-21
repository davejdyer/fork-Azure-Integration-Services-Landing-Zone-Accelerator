param keyVaultName string
param keyVaultTenantId string
param privateEndpointSubnet string
param privateEndpointVNET string
param privateEndpointVNETResourcegroup string
param privateDnsResourceGroup string
param privateDnsSubscriptionID string

var ltKeyVault = uri(deployment().properties.templateLink.uri, '../components/keyVault.json')
var ltPrivateEndpoint = uri(deployment().properties.templateLink.uri, '../components/privateEndpoint.json')

module deploy_KeyVault '../components/keyVault.json' = {
  name: 'deploy-KeyVault'
  params: {
    keyVaultName: keyVaultName
    tenantId: keyVaultTenantId
  }
}

module deploy_privateendpoint_keyvault '../components/privateEndpoint.json' = {
  name: 'deploy-privateendpoint-keyvault'
  params: {
    privateEndpointName: 'pep-${keyVaultName}'
    privateEndpointResource: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
    privateEndpointSubnet: privateEndpointSubnet
    privateEndpointVNET: privateEndpointVNET
    privateEndpointVNETResourcegroup: privateEndpointVNETResourcegroup
    privateEndpointGroupID: 'vault'
    privateDnsZoneName: 'privatelink.vaultcore.azure.net'
    privateDnsResourceGroup: privateDnsResourceGroup
    privateDnsSubscriptionID: privateDnsSubscriptionID
  }
  dependsOn: [
    deploy_KeyVault
  ]
}
