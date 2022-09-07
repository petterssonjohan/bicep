@description('storage account name')
param namePrefix string = 'st${uniqueString(resourceGroup().name)}'

@description('storage account location')
param location string = 'west europe' //north eu

module storageModule '../../modules/storages.bicep' = {
  name: 'storageDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

// module serviceBus '../../modules/serviceBus.bicep' = {
//   name: 'serviceBusDeploy'
//   params: {
//     location: location
//     namePrefix: namePrefix
//   }
// }

module eventGrid '../../modules/eventgrid.bicep' = {
  name: 'eventGridDeploy'
  params: {
    location: location
    namePrefix: namePrefix
    blobSourceId: storageModule.outputs.storageAccountId
  }
}
