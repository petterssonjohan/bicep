@description('storage account name')
param namePrefix string = 'st'

@description('storage account location')
param location string = 'west europe' //north eu

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${namePrefix}'
  location: location
}

module storageModule '../../modules/storages.bicep' = {
  name: 'storageDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
  scope: rg
}

// amodule serviceBus '../../modules/serviceBus.bicep' = {
//   name: 'serviceBusDeploy'
//   params: {
//     location: location
//     namePrefix: namePrefix
//   }
// }

@description('Provide a name for the system topic.')
param systemTopicName string = 'mystoragesystemtopic'

@description('Provide a name for the Event Grid subscription.')
param eventSubName string = 'subToStorage'
module eventGrid '../../modules/eventgrid.bicep' = {
  name: 'eventGridDeploy'
  params: {
    location: location
    systemTopicName: systemTopicName
    storageAccountId: storageModule.outputs.storageAccountId
    eventSubName: eventSubName
    storageAccountName: storageModule.outputs.storageAccountName
  }
  scope: rg
}
