param location string
param namePrefix string

param storageAccountId string
param storageAccountName string
param resourceGroupName string

// resource systemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
//   name: '${namePrefix}-systemtopic'
//   location: location
//   properties: {
//     source: storageAccountId
//     topicType: 'Microsoft.Storage.StorageAccounts'
//   }
//   tags: {
//     'BUSINESS-AREA': 'SPT'
//     'RUNTIME-ENVIRONMENT': 'test' //ENVIRONMENT_TYPE
//   }
// }

resource topicEvent 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: '${namePrefix}-eventsubscription'
  properties: {
    destination: {
      properties: {
        resourceId: '/subscriptions/bf558742-a412-4a60-88c4-733121e9580f/resourceGroups/${resourceGroupName}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
        queueName: '${namePrefix}-queue'
      }
      endpointType: 'StorageQueue'
    }
    filter: {
      subjectBeginsWith: '/blobServices/default/containers/servicedata'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }
}
