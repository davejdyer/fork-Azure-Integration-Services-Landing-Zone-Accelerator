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

@description('API Mangement Administrator Email')
param apimAdminEmail string = 'admin@domain.com'

@description('API Mangement Organsiation Name')
param apimOrganisation string = 'Organisation'

var platform = {
  systemPrefix: systemPrefix
  environment: environment
  region: resourceGroup().location
}
var nameSuffix = '-${systemPrefix}-${environment}-${platform.region}-01'
var keyVault = {
  name: 'kv${platform.systemPrefix}${platform.environment}${uniqueString(resourceGroup().id)}'
}
var storage = {
  name: 'stg${platform.systemPrefix}${platform.environment}${uniqueString(resourceGroup().id)}'
}
var logicApp = {
  name: 'logic${nameSuffix}'
}
var apim = {
  name: 'apim${nameSuffix}'
  tier: 'Developer'
  capacity: '1'
  identity: 'None'
  adminEmail: apimAdminEmail
  organisation: apimOrganisation
}
var serviceBusName = 'sbus${nameSuffix}'
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
}

module caf_ais_vnet 'templates/vnet/vnet.json' = {
  name: 'caf-ais-vnet'
  params: {
    vNet: vNet
  }
}

module caf_ais_key_vault_with_pe 'templates/kv/keyVaultWithPE.json' = {
  name: 'caf-ais-key-vault-with-pe'
  params: {
    keyVaultName: keyVault.name
    keyVaultTenantId: subscription().tenantId
    privateEndpointSubnet: vNet.privateLink.name
    privateEndpointVNET: vNet.name
    privateEndpointVNETResourcegroup: resourceGroup().name
    privateDnsResourceGroup: resourceGroup().name
    privateDnsSubscriptionID: subscription().id
  }
}
