param namePrefix string
param location string
param blobSourceId string

resource eventTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: '${namePrefix}-topic'
  location: location
  properties: {
    source: blobSourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource topicEvent 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  dependsOn: [
    eventTopic
  ]
  name: '${namePrefix}-event'
  properties: {

    destination: {
      properties: {
        resourceId: '/subscriptions/bf558742-a412-4a60-88c4-733121e9580f/resourceGroups/rg-${namePrefix}/providers/Microsoft.Storage/storageaccounts/${namePrefix}'
        queueName: 'default'
      }
      endpointType: 'StorageQueue'
    }
    filter: {
      subjectBeginsWith: '/blobServices/default/containers/servicedata'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      enableAdvancedFilteringOnArrays: false
    }

    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
