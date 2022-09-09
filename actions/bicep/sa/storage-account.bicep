param namePrefix string
param location string

module storageModule '../../../modules/storages.bicep' = {
  name: 'storageDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

@description('Provide a name for the system topic.')
param systemTopicName string = 'mystoragesystemtopic'
@description('Provide a name for the Event Grid subscription.')
param eventSubName string = 'subToStorage'
module eventGrid '../../../modules/eventgrid.bicep' = {
  name: 'eventGridDeploy'
  params: {
    location: location
    systemTopicName: systemTopicName
    storageAccountId: storageModule.outputs.storageAccountId
    eventSubName: eventSubName
    storageAccountName: storageModule.outputs.storageAccountName
    resourceGroupName: 'rg-${namePrefix}'
  }
}

module eventHub '../../../modules/eventhub.bicep' = {
  name: 'eventHubDeploy'
  params: {
    location: location
  }
}
