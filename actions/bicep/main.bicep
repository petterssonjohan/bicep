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
  scope: rg
}
