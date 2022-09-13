param namePrefix string
param location string
param tags object

resource servicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'spt-weu-sp-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
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
