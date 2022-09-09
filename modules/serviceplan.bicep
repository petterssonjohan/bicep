param namePrefix string
param location string

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
  tags: {
    'BUSINESS-AREA': 'SPT'
    'RUNTIME-ENVIRONMENT': 'test' //ENVIRONMENT_TYPE
  }
}
