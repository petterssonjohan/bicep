param namePrefix string
param location string
param hostingPlanId string
param tags object

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: '${namePrefix}-spt-weu-af-context-servicedataproc-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    storageAccountRequired: true
    serverFarmId: hostingPlanId
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
  tags: tags
}

//Function to Subnet configuration missing below..?
