param location string
param namePrefix string
param tags object

//Create a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'sptweusasvcdataproc${namePrefix}${tags['RUNTIME-ENVIRONMENT']}'
  location: location
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
  sku: {
    name: 'Standard_LRS'
  }
  tags: tags
}
var azStorageAccountPrimaryAccessKey = listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value

// Create a storage blob container for service data and for device context
var containers = [ 'servicedata', 'devicecontext' ]
resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for container in containers: {
  name: 'sptweusasvcdataproc${namePrefix}${tags['RUNTIME-ENVIRONMENT']}/default/${container}'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
  dependsOn: [ storageAccount ]
}]

//Create a lifecycle management rule for that storage account
resource management_policies 'Microsoft.Storage/storageAccounts/managementPolicies@2022-05-01' = {
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

resource storage_queues 'Microsoft.Storage/storageAccounts/queueServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
  }
}
resource storage_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-05-01' = {
  name: 'logs-uploaded-${namePrefix}'
  parent: storage_queues
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output azStorageAccountPrimaryAccessKey string = azStorageAccountPrimaryAccessKey
