param vNet object
param platform object
param apim object

resource apim_name 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apim.name
  location: platform.region
  sku: {
    name: apim.tier
    capacity: 1
  }
  properties: {
    publisherEmail: apim.adminEmail
    publisherName: apim.organisation
  }
  dependsOn: []
}
