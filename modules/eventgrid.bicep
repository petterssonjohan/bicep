//param location string
param namePrefix string

//param storageAccountId string
param storageAccountName string
param resourceGroupName string
param subscriptionId string
param tags object

resource topicEvent 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: 'spt-weu-evgs-svcdataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  properties: {
    deliveryWithResourceIdentity: {
      destination: {
        endpointType: 'StorageQueue'
        properties: {
          resourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
          queueName: 'logs-uploaded-${namePrefix}'
        }
      }
    }

    filter: {
      subjectBeginsWith: '/blobServices/default/containers/servicedata'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }
}
