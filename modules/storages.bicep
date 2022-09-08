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

@description('Provide a name for the system topic.')
param systemTopicName string = 'mystoragesystemtopic'

@description('Provide a name for the Event Grid subscription.')
param eventSubName string = 'subToStorage'

resource systemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: systemTopicName
  location: location
  properties: {
    source: storageAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

@description('Provide the URL for the WebHook to receive events. Create your own endpoint for events.')
param endpoint string = 'https://www.example.com'

resource topicEvent 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: eventSubName
  parent: systemTopic
  properties: {
    destination: {
      properties: {
        endpointUrl: endpoint
      }
      endpointType: 'WebHook'
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
    }
  }
  // properties: {
  //   destination: {
  //     properties: {
  //       resourceId: '/subscriptions/bf558742-a412-4a60-88c4-733121e9580f/resourceGroups/rg-st12123123123/providers/Microsoft.Storage/storageAccounts/${storageAccount.name}'
  //       queueName: 'default'
  //     }
  //     endpointType: 'StorageQueue'
  //   }
  //   filter: {
  //     subjectBeginsWith: '/blobServices/default/containers/servicedata'
  //     includedEventTypes: [
  //       'Microsoft.Storage.BlobCreated'
  //     ]
  //   }
  // }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
//output storageAccount resource = storageAccount
