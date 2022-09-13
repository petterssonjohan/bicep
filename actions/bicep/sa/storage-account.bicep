param namePrefix string
param location string
param tags object

module storageModule '../../../modules/storages.bicep' = {
  name: '${namePrefix}-storage-deploy'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
  }
}

output storageAccountId string = storageModule.outputs.storageAccountId
output storageAccountName string = storageModule.outputs.storageAccountName
