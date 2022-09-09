param location string
param namePrefix string

resource ehNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: '${namePrefix}-eventhub-namespace'
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
  name: '${namePrefix}-eventhub'
  parent: ehNamespace
  properties: {
    messageRetentionInDays: 7
    partitionCount: 2
  }
}

resource eventHubAccessPolicyListen 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: '${namePrefix}-asa-servicedataproc-listen'
  parent: ehNamespace
  properties: {
    rights: [ 'Listen' ]
  }
}

resource eventHubAccessPolicySend 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: '${namePrefix}-af-data-servicedataproc-send'
  parent: ehNamespace
  properties: {
    rights: [ 'Send' ]
  }
}

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: '${namePrefix}-evhcg-asa-customer-fanout'
  parent: eventHub
}
