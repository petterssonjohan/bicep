param namePrefix string
param location string
param storageAccountName string
param subscriptionId string
module eventGrid '../../../modules/eventgrid.bicep' = {
  name: '${namePrefix}-eventgrid-deploy'
  params: {
    subscriptionId: subscriptionId
    storageAccountName: storageAccountName
    resourceGroupName: '${namePrefix}-rg'
    namePrefix: namePrefix
  }
}

module eventHub '../../../modules/eventhub.bicep' = {
  name: '${namePrefix}-eventhub-deploy'
  params: {
    location: location
    namePrefix: namePrefix
  }
}
