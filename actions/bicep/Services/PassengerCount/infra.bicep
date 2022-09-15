/* INFRA BICEP FOR Passanger Count (APC) Service Project */

@description('Subscription ID in Azure')
param subscriptionId string

@description('Name prefix for resources')
param serviceName string = 'apc' //apc | ji | voip | nme

@description('Location for resources')
param location string = 'west europe'

@description('Tags for resources')
param tags object

@description('VNET Target Resource Group')
param vnetResourceGroup string

targetScope = 'subscription'
var businessArea = 'spt'
var loc = 'weu'

/* Will Create a new Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${businessArea}-${loc}-rg-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
}

var serviceDataName = 'service-data'

@description('Provide unique identifier for release')
param releaseId string = newGuid()

var blobContainers = [
  {
    name: 'device-context'
    enablePublicAccess: false
  }
  {
    name: serviceDataName
    enablePublicAccess: false
  }
]

var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageAccountName = '${businessArea}${loc}sa${serviceName}${tags['RUNTIME-ENVIRONMENT']}'

module storageAccount '../../modules/storageaccount.bicep' = {
  name: 'sa-${releaseId}'
  scope: rg
  params: {
    name: storageAccountName
    location: location
    serviceName: serviceName
    tags: tags
    blobContainers: blobContainers
    roleAssignments: [
      {
        principalId: deviceContextFunction.outputs.deviceContextPrincipalId
        roleId: storageBlobDataContributorRoleId
      }
      {
        principalId: serviceDataFunction.outputs.serviceDataPrincipalId
        roleId: storageBlobDataContributorRoleId
      }
    ]
    managementPolicies: {
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
                  '${serviceDataName}/'
                ]
              }
            }
          }
        ]
      }
    }
  }
}

/* Event Grid */
module eventGrid '../../modules/eventgrid.bicep' = {
  name: 'eventGrid-${releaseId}'
  scope: rg
  params: {
    serviceName: serviceName
    systemTopicName: '${businessArea}-${loc}-egt-${serviceName}-logs-uploaded-${tags['RUNTIME-ENVIRONMENT']}'
    eventSubscriptionName: '${businessArea}-${loc}-evgs-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    tags: tags
    location: location
    topicEventProperties: {
      destination: {
        endpointType: 'StorageQueue'
        properties: {
          resourceId: '/subscriptions/${subscriptionId}/resourceGroups/${rg.name}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
          queueName: 'logs-uploaded-${serviceName}'
          queueMessageTimeToLiveInSeconds: 604800
        }

      }
      filter: {
        includedEventTypes: [
          'Microsoft.Storage.BlobCreated'
        ]
        subjectBeginsWith: '/blobServices/default/containers/${serviceDataName}'
      }
    }
  }
}

/* Event Hub */
module eventHub '../../modules/eventhub.bicep' = {
  name: 'eventHub-${releaseId}'
  scope: rg
  params: {
    location: location
    name: '${businessArea}-${loc}-evh-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    namespaceName: '${businessArea}-${loc}-evhns-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    tags: tags
    authorizationListenRuleName: 'asa-${serviceName}-listen'
    authorizationSendRuleName: 'af-data-${serviceName}-send'
    consumerGroupName: 'evhcg-asa-customer-fanout-${serviceName}'
  }
}

module redis '../../modules/redis.bicep' = {
  name: 'redis-${releaseId}'
  scope: rg
  params: {
    location: location
    name: '${businessArea}-${loc}-redis-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    tags: tags
  }
}

module appService '../../modules/appservice.bicep' = {
  scope: rg
  name: 'appService-${releaseId}'
  params: {
    name: '${businessArea}-${loc}-sp-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    planSku: tags['RUNTIME-ENVIRONMENT'] == 'prod' ? 'S1' : 'F1'
    location: location
  }
}

module network '../../modules/network.bicep' = {
  name: 'network-${releaseId}'
  scope: resourceGroup(subscriptionId, vnetResourceGroup)
  params: {
    publicIpAddressName: 'net-publicipaddress-${serviceName}'
    natGatewayName: 'dms-${loc}-natg-${tags['RUNTIME-ENVIRONMENT']}'
    vnetName: 'dms-${loc}-vnet-${tags['RUNTIME-ENVIRONMENT']}'
    vnetSubnetName: '${businessArea}-${loc}-subnet-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    location: location
  }
}

module deviceContextFunction '../../modules/function-devicecontext.bicep' = {
  name: 'deviceContext-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}-${loc}-af-context-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    appServicePlanId: appService.outputs.appServicePlanId
    location: location
    tags: tags
  }
}

module serviceDataFunction '../../modules/function-servicedata.bicep' = {
  name: 'serviceData-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}-${loc}-af-data-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    appServicePlanId: appService.outputs.appServicePlanId
    location: location
    tags: tags
  }
}

module cosmosAccount '../../modules/cosmos.bicep' = {
  name: 'cosmos-${releaseId}'
  scope: rg
  params: {
    accountName: '${businessArea}-${loc}-cosmos-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
    databaseName: '${serviceDataName}-${serviceName}'
    location: location
    containerName: 'data-${serviceName}'
    tags: tags
    containerProperties: {
      options: {
        autoscaleSettings: {
          maxThroughput: 4000
        }
      }
      resource: {
        id: 'data-${serviceName}'
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
}
