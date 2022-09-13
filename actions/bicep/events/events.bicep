param namePrefix string
param location string
param storageAccountName string
param subscriptionId string
param tags object
param storageAccountId string
module eventGrid '../../../modules/eventgrid.bicep' = {
  name: '${namePrefix}-eventgrid-deploy'
  params: {
    subscriptionId: subscriptionId
    storageAccountName: storageAccountName
    resourceGroupName: 'spt-weu-rg-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
    namePrefix: namePrefix
    tags: tags
    location: location
    blobSourceId: storageAccountId
  }
}

module eventHub '../../../modules/eventhub.bicep' = {
  name: '${namePrefix}-eventhub-deploy'
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}

//no secrets should be passed..
output EVENTHUB_ACCESS_POLICY_KEY string = eventHub.outputs.EVENTHUB_ACCESS_POLICY_KEY
