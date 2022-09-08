param systemTopicName string
param location string
param storageAccountId string
param eventSubName string
param resourceGroup string
param storageAccountName string
param storageAccount resource 'Microsoft.Storage/storageAccounts@2021-09-01'

resource systemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: systemTopicName
  location: location
  properties: {
    source: storageAccountId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource topicEvent 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: eventSubName
  scope: storageAccount
  properties: {
    destination: {
      properties: {
        resourceId: '/subscriptions/bf558742-a412-4a60-88c4-733121e9580f/resourceGroups/rg-st12123123123/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
        queueName: 'default'
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
