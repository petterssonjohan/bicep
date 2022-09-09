@description('storage account name')
param namePrefix string = 'st'

@description('storage account location')
param location string = 'west europe'

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${namePrefix}'
  location: location
  tags: {

  }
}

module storageAccount 'sa/storage-account.bicep' = {
  name: 'storageAccount'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

module redis 'redis/redis.bicep' = {
  name: 'redisCache'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    dmsResourceGroup: 'dmsResourceGroup'
    dmsSubscriptionID: 'bf558742-a412-4a60-88c4-733121e9580f'
  }
}

// module storageModule '../../modules/storages.bicep' = {
//   name: 'storageDeploy'
//   params: {
//     namePrefix: namePrefix
//     location: location
//   }
//   scope: rg
// }

// @description('Provide a name for the system topic.')
// param systemTopicName string = 'mystoragesystemtopic'

// @description('Provide a name for the Event Grid subscription.')
// param eventSubName string = 'subToStorage'
// module eventGrid '../../modules/eventgrid.bicep' = {
//   name: 'eventGridDeploy'
//   params: {
//     location: location
//     systemTopicName: systemTopicName
//     storageAccountId: storageModule.outputs.storageAccountId
//     eventSubName: eventSubName
//     storageAccountName: storageModule.outputs.storageAccountName
//     resourceGroupName: rg.name
//   }
//   scope: rg
// }

// module eventHub '../../modules/eventhub.bicep' = {
//   name: 'eventHubDeploy'
//   params: {
//     location: location
//   }
//   scope: rg
// }
