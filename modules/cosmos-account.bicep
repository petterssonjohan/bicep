param namePrefix string
param location string
param tags object

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
  name: 'spt-weu-cosmos-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
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
  name: 'servicedata-${namePrefix}'
  properties: {
    resource: {
      id: 'servicedata-${namePrefix}'
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: 'data-${namePrefix}'
  properties: {
    options: {
      autoscaleSettings: {
        maxThroughput: 4000
      }
    }
    resource: {
      id: 'data-${namePrefix}'
      partitionKey: {
        paths: [
          '/Serial'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/_etag/?'
          }
        ]
      }
      defaultTtl: 2592000
    }
  }
}
