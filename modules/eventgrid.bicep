param location string
param namePrefix string

param blobSourceId string
param storageAccountName string
param resourceGroupName string
param subscriptionId string
param tags object

resource eventTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: 'spt-weu-egt-svcdataproc-logs-uploaded-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
  properties: {
    source: blobSourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

resource topicEvent 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: 'spt-weu-evgs-svcdataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  parent: eventTopic
  properties: {
    destination: {
      endpointType: 'StorageQueue'
      properties: {
        resourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
        queueName: 'logs-uploaded-${namePrefix}'
        queueMessageTimeToLiveInSeconds: 604800
      }

    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      subjectBeginsWith: '/blobServices/default/containers/servicedata'
    }
  }
}
