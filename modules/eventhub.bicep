param location string

resource ehNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: 'eventhubnamespace01923843'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    zoneRedundant: true
    isAutoInflateEnabled: true
    maximumThroughputUnits: 20
  }
  tags: {
    'BUSINESS-AREA': 'SPT'
    'RUNTIME-ENVIRONMENT': 'test' //ENVIRONMENT_TYPE
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: 'eventhub'
  parent: ehNamespace
  properties: {
    messageRetentionInDays: 7
    partitionCount: 2
  }
}

resource eventHubAccessPolicyListen 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'asa-servicedataproc-listen'
  parent: ehNamespace
  properties: {
    rights: [ 'Listen' ]
  }
}

resource eventHubAccessPolicySend 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'af-data-servicedataproc-send'
  parent: ehNamespace
  properties: {
    rights: [ 'Send' ]
  }
}

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: 'evhcg-asa-customer-fanout'
  parent: eventHub
}
