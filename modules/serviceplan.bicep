param namePrefix string
param location string
param tags object

resource servicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${namePrefix}-serviceplan'
  location: location
  properties: {
    perSiteScaling: true
    targetWorkerCount: 4
  }
  sku: {
    name: 'f1'
  }
  kind: 'linux'
  tags: tags
}
output hostingPlanId string = servicePlan.id
output hostingPlan object = servicePlan
