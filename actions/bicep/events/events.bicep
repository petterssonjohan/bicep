param namePrefix string
param location string
param storageAccountId string
param storageAccountName string

@description('Provide a name for the system topic.')
param systemTopicName string = 'mystoragesystemtopic'
@description('Provide a name for the Event Grid subscription.')
param eventSubName string = 'subToStorage'
module eventGrid '../../../modules/eventgrid.bicep' = {
  name: 'eventGridDeploy'
  params: {
    location: location
    systemTopicName: systemTopicName
    storageAccountId: storageAccountId
    eventSubName: eventSubName
    storageAccountName: storageAccountName
    resourceGroupName: 'rg-${namePrefix}'
  }
}

module eventHub '../../../modules/eventhub.bicep' = {
  name: 'eventHubDeploy'
  params: {
    location: location
  }
}
