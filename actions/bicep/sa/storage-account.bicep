param namePrefix string
param location string

module storageModule '../../../modules/storages.bicep' = {
  name: '${namePrefix}-storage-deploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
output storageAccountId string = storageModule.outputs.storageAccountId
output storageAccountName string = storageModule.outputs.storageAccountName
