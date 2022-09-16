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

@description('TenantId')
param tenantId string

targetScope = 'subscription'
var businessArea = 'spt'
var loc = 'weu'
var env = tags['RUNTIME-ENVIRONMENT']

/* Will Create a new Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${businessArea}-${loc}-rg-${serviceName}-${env}'
  location: location
}

/* Create KeyVault */
module keyvault '../../modules/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    tenantId: tenantId
    location: location
    serviceName: serviceName
    tags: tags
  }
}

var serviceDataName = 'service-data'
var deviceContextName = 'device-context'

@description('Provide unique identifier for release')
param releaseId string = newGuid()

var blobContainers = [
  {
    name: deviceContextName
    enablePublicAccess: false
    metadata: {}
  }
  {
    name: serviceDataName
    enablePublicAccess: false
    metadata: {}
  }
]

var storageBlobDataContributorRoleId = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var storageAccountName = '${businessArea}${loc}sa${serviceName}${env}'

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
    systemTopicName: '${businessArea}-${loc}-egt-${serviceName}-logs-uploaded-${env}'
    eventSubscriptionName: '${businessArea}-${loc}-evgs-${serviceName}-${env}'
    tags: tags
    location: location
    storageAccountId: storageAccount.outputs.storageAccountId
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
    name: '${businessArea}-${loc}-evh-${serviceName}-${env}'
    namespaceName: '${businessArea}-${loc}-evhns-${serviceName}-${env}'
    tags: tags
    authorizationListenRuleName: 'asa-${serviceName}-listen'
    authorizationSendRuleName: 'af-data-${serviceName}-send'
    consumerGroupName: 'evhcg-asa-customer-fanout-${serviceName}'
    serviceName: serviceName
    sku: {
      name: 'Standard'
      tier: 'Standard'
      capacity: 1
    }
  }
}

// module redis '../../modules/redis.bicep' = {
//   name: 'redis-${releaseId}'
//   scope: rg
//   params: {
//     location: location
//     name: '${businessArea}-${loc}-redis-${serviceName}-${env}'
//     tags: tags
//   }
// }

// module appService '../../modules/appservice.bicep' = {
//   scope: rg
//   name: 'appService-${releaseId}'
//   params: {
//     name: '${businessArea}-${loc}-sp-${serviceName}-${env}'
//     planSku: env == 'prod' ? 'S1' : 'F1'
//     location: location
//   }
// }

// /* So Costly.. */
// // module network '../../modules/network.bicep' = {
// //   name: 'network-${releaseId}'
// //   scope: resourceGroup(subscriptionId, vnetResourceGroup)
// //   params: {
// //     publicIpAddressName: 'net-publicipaddress-${serviceName}'
// //     natGatewayName: 'dms-${loc}-natg-${tags['RUNTIME-ENVIRONMENT']}'
// //     vnetName: 'dms-${loc}-vnet-${tags['RUNTIME-ENVIRONMENT']}'
// //     vnetSubnetName: '${businessArea}-${loc}-subnet-${serviceName}-${tags['RUNTIME-ENVIRONMENT']}'
// //     location: location
// //   }
// // }

// module deviceContextFunction '../../modules/function-devicecontext.bicep' = {
//   name: 'deviceContext-${releaseId}'
//   scope: rg
//   params: {
//     name: '${businessArea}-${loc}-af-context-${serviceName}-${env}'
//     appServicePlanId: appService.outputs.appServicePlanId
//     location: location
//     tags: tags
//   }
// }

// module serviceDataFunction '../../modules/function-servicedata.bicep' = {
//   name: 'serviceData-${releaseId}'
//   scope: rg
//   params: {
//     name: '${businessArea}-${loc}-af-data-${serviceName}-${env}'
//     appServicePlanId: appService.outputs.appServicePlanId
//     location: location
//     tags: tags
//   }
// }

// module cosmos '../../modules/cosmos.bicep' = {
//   name: 'cosmos-${releaseId}'
//   scope: rg
//   params: {
//     accountName: '${businessArea}-${loc}-cosmos-${serviceName}-${env}'
//     databaseName: '${serviceDataName}-${serviceName}'
//     location: location
//     containerName: 'data-${serviceName}'
//     tags: tags
//     serviceName: serviceName
//     containerProperties: {
//       options: {
//         autoscaleSettings: {
//           maxThroughput: 4000
//         }
//       }
//       resource: {
//         id: 'data-${serviceName}'
//         partitionKey: {
//           paths: [
//             '/Serial'
//           ]
//           kind: 'Hash'
//         }
//         indexingPolicy: {
//           indexingMode: 'consistent'
//           includedPaths: [
//             {
//               path: '/*'
//             }
//           ]
//           excludedPaths: [
//             {
//               path: '/_etag/?'
//             }
//           ]
//         }
//         defaultTtl: 2592000
//       }
//     }
//   }
// }

// resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
//   name: 'kv-${serviceName}'
//   scope: rg
// }

// module streamAnalytics '../../modules/streamanalytics.bicep' = {
//   name: 'streamAnalytics-${releaseId}'
//   scope: rg
//   params: {
//     name: '${businessArea}-${loc}-asa-${serviceName}-${env}'
//     input: 'input-${eventHub.name}'
//     output: 'output-${cosmos.name}'
//     location: location
//     tags: tags
//     eventhubAccessPolicyPrimaryKey: kv.getSecret('asa-${serviceName}-listen-pk')
//     eventhubNamespaceName: '${businessArea}-${loc}-evhns-${serviceName}-${env}'
//     eventhubAuthorizationListenRuleName: 'asa-${serviceName}-listen'
//     eventhubName: '${businessArea}-${loc}-evh-${serviceName}-${env}'
//     eventhubConsumerGroupName: 'evhcg-asa-customer-fanout-${serviceName}'
//     cosmosAccountName: '${businessArea}-${loc}-cosmos-${serviceName}-${env}'
//     cosmosPrimaryKey: kv.getSecret('${businessArea}-${loc}-cosmos-${serviceName}-${env}-pcs')
//     cosmosDatabaseName: '${serviceDataName}-${serviceName}'
//     cosmosContainerName: 'data-${serviceName}'
//     cosmosPartialKey: '/Serial'
//     transformationName: 'transformation'
//   }
// }
