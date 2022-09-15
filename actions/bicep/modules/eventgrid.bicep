param location string
param serviceName string
param tags object
param systemTopicName string
param topicEventProperties object
param eventSubscriptionName string
param storageAccountId string

// resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
//   name: 'sptweusa${serviceName}${tags['RUNTIME-ENVIRONMENT']}'
// }

resource eventTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: systemTopicName
  location: location
  properties: {
    source: storageAccountId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
  tags: tags
}

resource topicEvent 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: eventSubscriptionName
  parent: eventTopic
  properties: topicEventProperties
}
