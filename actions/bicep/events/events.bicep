param namePrefix string
param location string
param storageAccountId string
param storageAccountName string

module eventGrid '../../../modules/eventgrid.bicep' = {
  name: 'eventGridDeploy'
  params: {
    location: location
    storageAccountId: storageAccountId
    storageAccountName: storageAccountName
    resourceGroupName: '${namePrefix}-rg'
    namePrefix: namePrefix
  }
}

module eventHub '../../../modules/eventhub.bicep' = {
  name: 'eventHubDeploy'
  params: {
    location: location
    namePrefix: namePrefix
  }
}
