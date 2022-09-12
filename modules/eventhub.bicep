param location string
param namePrefix string
param tags object

resource ehNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: 'spt-weu-evhns-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
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
  tags: tags
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: 'spt-weu-evh-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  parent: ehNamespace
  properties: {
    messageRetentionInDays: 7
    partitionCount: 2
  }
}

resource eventHubAccessPolicyListen 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'asa-servicedataproc-listen-${namePrefix}'
  parent: ehNamespace
  properties: {
    rights: [ 'Listen' ]
  }
}

resource eventHubAccessPolicySend 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'af-data-servicedataproc-send-${namePrefix}'
  parent: ehNamespace
  properties: {
    rights: [ 'Send' ]
  }
}

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: 'evhcg-asa-customer-fanout-${namePrefix}'
  parent: eventHub
}
