param name string
param input string
param output string
param location string
param tags object

param eventhubNamespaceName string
param eventhubAuthorizationListenRuleName string

@secure()
param eventhubAccessPolicyPrimaryKey string
param eventhubName string
param eventhubConsumerGroupName string

param cosmosAccountName string

@secure()
param cosmosPrimaryKey string
param cosmosDatabaseName string
param cosmosContainerName string
param cosmosPartialKey string

param transformationName string

resource streamingJob 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'Standard'
    }
    outputErrorPolicy: 'Drop'
    dataLocale: 'en-US'
  }
  tags: tags
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: 'kv-apc'
}

resource eventhubInput 'Microsoft.StreamAnalytics/streamingjobs/inputs@2021-10-01-preview' = {
  name: input
  parent: streamingJob
  properties: {
    type: 'Stream'
    datasource: {
      type: 'Microsoft.EventHub/EventHub'
      properties: {
        authenticationMode: 'ConnectionString'
        serviceBusNamespace: eventhubNamespaceName
        sharedAccessPolicyName: eventhubAuthorizationListenRuleName
        sharedAccessPolicyKey: eventhubAccessPolicyPrimaryKey
        eventHubName: eventhubName
        consumerGroupName: eventhubConsumerGroupName
      }
    }
    serialization: {
      type: 'Json'
      properties: {
        encoding: 'UTF8'
      }
    }

  }
}

resource eventhubOutput 'Microsoft.StreamAnalytics/streamingjobs/outputs@2021-10-01-preview' = {
  name: output
  parent: streamingJob
  properties: {
    datasource: {
      type: 'Microsoft.Storage/DocumentDB'
      properties: {
        authenticationMode: 'Msi'
        accountId: cosmosAccountName
        accountKey: cosmosPrimaryKey
        database: cosmosDatabaseName
        collectionNamePattern: cosmosContainerName
        partitionKey: cosmosPartialKey
        documentId: ''
      }
    }
    serialization: {
      type: 'Json'
      properties: {
        encoding: 'UTF8'
      }
    }
  }
}

/* Not Building Stream Analytics query from Template.. */

resource streamAnalyticTransformation 'Microsoft.StreamAnalytics/streamingjobs/transformations@2021-10-01-preview' = {
  name: transformationName
  parent: streamingJob
  properties: {
    query: 'SELECT * INTO ${output} FROM ${input}'
    streamingUnits: 3
  }
}
