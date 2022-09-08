param location string

resource ehNamespace 'Microsoft.EventHub/namespaces@2022-01-01-preview' = {
  name: 'EventhubNamespace'
  location: location
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-01-01-preview' = {
  name: 'eventhub'
  parent: ehNamespace
}

resource eventHubAccessPolicyListen 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'asa-servicedataproc-listen'
  parent: ehNamespace
  properties: {
    rights: [ 'listen ' ]
  }
}

resource eventHubAccessPolicySend 'Microsoft.EventHub/namespaces/authorizationRules@2022-01-01-preview' = {
  name: 'af-data-servicedataproc-send'
  parent: ehNamespace
  properties: {
    rights: [ 'send ' ]
  }
}

resource eventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-01-01-preview' = {
  name: 'evhcg-asa-customer-fanout'
  parent: eventHub
}
