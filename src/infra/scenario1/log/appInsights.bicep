param vNet object
param platform object
param appInsights object
param logAnalytics object

resource appInsights_name 'microsoft.insights/components@2020-02-02' = {
  name: appInsights.name
  location: resourceGroup().location
  kind: 'web'
  properties: {
    ApplicationId: appInsights.name
    WorkspaceResourceId: resourceId('microsoft.operationalinsights/workspaces', logAnalytics.name)
  }
}
