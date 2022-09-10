param namePrefix string
param location string
param storageAccountName string
param subscriptionId string
module eventGrid '../../../modules/eventgrid.bicep' = {
  name: 'eventGridDeploy'
  params: {
    subscriptionId: subscriptionId
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
