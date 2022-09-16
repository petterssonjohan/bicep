param location string
param tags object
param accountName string
param databaseName string
param containerName string
param containerProperties object
param serviceName string
param defaultConsistencyLevel string = 'Eventual'

var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
}
var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

/* Cosmos Account */
resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: accountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    enableFreeTier: true //for dev, now when testing
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
  }
  tags: tags
}
output account object = account

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: containerName
  properties: containerProperties
}

module cosmosKeyVaultSecretPrimaryConnectionString '../modules/secret.bicep' = {
  name: 'cosmosKeyVaultSecretPrimaryConnectionString'
  params: {
    keyVaultName: 'kv-${serviceName}'
    secretName: '${accountName}-pcs'
    secretValue: listKeys(account.id, account.apiVersion).primaryConnectionString
  }
}

output keyVaultSecretName string = cosmosKeyVaultSecretPrimaryConnectionString.outputs.keyVaultSecretName
