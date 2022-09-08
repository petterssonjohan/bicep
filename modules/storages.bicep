param location string
param namePrefix string

//Create a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: namePrefix
  location: location
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
  sku: {
    name: 'Standard_LRS'
  }
}

// Create a storage blob container for service data and for device context
var containers = [ 'servicedata', 'devicecontext' ]
resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = [for container in containers: {
  name: '${namePrefix}/default/${container}'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
  dependsOn: [ storageAccount ]
}]

//Create a lifecycle management rule for that storage account
resource management_policies 'Microsoft.Storage/storageAccounts/managementPolicies@2021-09-01' = {
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'delete-after-14-days'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                delete: {
                  daysAfterModificationGreaterThan: 14
                }
              }
              snapshot: {
                delete: {
                  daysAfterCreationGreaterThan: 14
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob', 'appendBlob'
              ]
              prefixMatch: [
                'servicedata/'
              ]
            }
          }
        }
      ]
    }
  }
  parent: storageAccount
}

resource storage_queues 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
