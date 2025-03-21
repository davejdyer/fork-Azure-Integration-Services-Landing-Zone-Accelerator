param vNet object
param platform object
param logAnalytics object

resource logAnalytics_name 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalytics.name
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 365
  }
}
