param name string
param input string
param output string
param location string
param tags object

param eventhubNamespaceName string
param eventhubAuthorizationListenRuleName string

param eventhubName string
param eventhubConsumerGroupName string

param cosmosAccountName string

param cosmosDatabaseName string
param cosmosContainerName string
param cosmosPartialKey string

param transformationName string

param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

param eventHubKeyVaultSecretName string
param cosmosKeyVaultSecretName string

module streamAnalytics './streamanalytics.bicep' = {
  name: 'streamAnalytics'
  params: {
    name: name
    input: input
    output: output
    location: location
    tags: tags
    eventhubAccessPolicyPrimaryKey: kv.getSecret(eventHubKeyVaultSecretName)
    eventhubNamespaceName: eventhubNamespaceName
    eventhubAuthorizationListenRuleName: eventhubAuthorizationListenRuleName
    eventhubName: eventhubName
    eventhubConsumerGroupName: eventhubConsumerGroupName
    cosmosAccountName: cosmosAccountName
    cosmosPrimaryKey: kv.getSecret(cosmosKeyVaultSecretName)
    cosmosDatabaseName: cosmosDatabaseName
    cosmosContainerName: cosmosContainerName
    cosmosPartialKey: cosmosPartialKey
    transformationName: transformationName
  }
  dependsOn: [ kv ]
}
