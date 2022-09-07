param namePrefix string
param location string
param blobSourceId string

resource eventTopic 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: '${namePrefix}-topic'
  location: location
  properties: {
    source: blobSourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource topicEvent 'Microsoft.EventGrid/eventSubscriptions@2021-12-01' = {
  dependsOn: [
    eventTopic
  ]
  name: '${namePrefix}-event'
  properties: {
    destination: {
      properties: {
        resourceId: '/subscriptions/${'bf558742-a412-4a60-88c4-733121e9580f'}/resourceGroups/${'deni-ra'}/providers/Microsoft.Storage/storageaccounts/${namePrefix}' //'${serviceBusId}/queues/${namePrefix}-queue'
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
