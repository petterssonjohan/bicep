param location string
param tags object
param name string
param namespaceName string
param authorizationListenRuleName string
param authorizationSendRuleName string
param consumerGroupName string
param sku object

resource ehNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: namespaceName
  location: location
  sku: sku
  properties: {
    zoneRedundant: true
    isAutoInflateEnabled: tags['RUNTIME-ENVIRONMENT'] == 'prod' ? true : false
    maximumThroughputUnits: tags['RUNTIME-ENVIRONMENT'] == 'prod' ? 20 : 0
  }
  tags: tags
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: name
  parent: ehNamespace
  properties: {
    messageRetentionInDays: 7
    partitionCount: 2
  }
}

resource eventHubAccessPolicyListen 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: authorizationListenRuleName
  parent: eventHub
  properties: {
    rights: [ 'Listen' ]
  }
}

resource eventHubAccessPolicySend 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-01-01-preview' = {
  name: authorizationSendRuleName
  parent: eventHub
  properties: {
    rights: [ 'Send' ]
  }
}

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: consumerGroupName
  parent: eventHub
}
