/* INFRA BICEP FOR Passanger Count (APC) Service Project */

@description('Subscription ID in Azure')
param subscriptionId string

@maxLength(3)
@description('Name prefix for resources')
param serviceName string = 'apc' //apc | ji | voip | nme

@description('Location for resources')
param location string = 'west europe'

@description('Tags for resources')
param tags object

targetScope = 'subscription'
var businessArea = 'spt'
var loc = 'weu'
var env = tags['RUNTIME-ENVIRONMENT']

@description('Provide unique identifier for release.')
param releaseId string = newGuid()

/* Will Create a new Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${businessArea}-${loc}-rg-${serviceName}-${env}'
  location: location
}

module userAssigned '../../modules/userassignedidentity.bicep' = {
  name: 'userAssignedIdentity-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}${serviceName}${env}'
    location: location
    tags: tags
  }
}

// var roleAssignmentName= guid(principalId, roleDefinitionID, resourceGroup().id)
// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
//   name: roleAssignmentName
//   properties: {
//     roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
//     principalId: principalId
//   }
// }

// module operatorSetup '../../modules/operatorSetup.bicep' = {
//   name: 'operatorSetup-deployment-${releaseId}'
//   params: {
//     operatorPrincipalId: deploymentOperatorId
//     appName: serviceName
//   }
//   scope: rg
// }

// // creates an user-assigned managed identity that will used by different azure resources to access each other.
// module msi '../../modules/msi.bicep' = {
//   name: 'msi-deployment'
//   params: {
//     location: location
//     managedIdentityName: '${serviceName}Identity'
//     operatorRoleDefinitionId: operatorSetup.outputs.roleId
//   }
//   scope: rg
// }

//for dev and test, random names so its easy to remove it and recreate
var kvName = env == 'prod' ? '${businessArea}-${loc}-kv-${serviceName}-${env}' : 'a${skip(uniqueString('${businessArea}-${loc}-kv-${serviceName}-${env}'), 8)}-${serviceName}-${env}'

module keyvault '../../modules/keyvault-resource-preserving-accesspolicy.bicep' = {
  name: 'kv-preserving_${releaseId}'
  params: {
    location: location
    keyVaultName: kvName
    tags: tags
    tenantId: userAssigned.outputs.tenantId
    identityPrincipalId: '${businessArea}${serviceName}${env}'
    deploymentOperatorId: userAssigned.outputs.identityPrincipalId
  }
  scope: rg
}

var serviceDataName = 'service-data'
var blobContainers = [
  {
    name: serviceDataName
    enablePublicAccess: false
    metadata: {}
  }
]
var buildInRoleStorageBlobDataOwner = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
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
        principalId: serviceDataFunction.outputs.principalId
        roleId: buildInRoleStorageBlobDataOwner
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
    keyVaultName: keyvault.outputs.keyVaultName
    sku: {
      name: 'Standard'
      tier: 'Standard'
      capacity: 1
    }
  }
}

module appService '../../modules/appservice.bicep' = {
  scope: rg
  name: 'appService-${releaseId}'
  params: {
    name: '${businessArea}-${loc}-sp-${serviceName}-${env}'
    planSku: env == 'prod' ? 'S1' : 'F1'
    location: location
  }
}

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

module serviceDataFunction '../../modules/azure-function.bicep' = {
  name: 'serviceData-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}-${loc}-af-data-${serviceName}-${env}'
    appServicePlanId: appService.outputs.appServicePlanId
    location: location
    tags: tags
    storageAccountRequired: true
  }
}

module cosmos '../../modules/cosmos.bicep' = {
  name: 'cosmos-${releaseId}'
  scope: rg
  params: {
    accountName: '${businessArea}-${loc}-cosmos-${serviceName}-${env}'
    databaseName: '${serviceDataName}-${serviceName}'
    location: location
    containerName: 'data-${serviceName}'
    tags: tags
    serviceName: serviceName
    keyVaultName: keyvault.outputs.keyVaultName
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

module streamAnalytics '../../modules/stream-analytic-input.bicep' = {
  name: 'streamAnalytics-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}-${loc}-asa-${serviceName}-${env}'
    input: 'input-${eventHub.name}'
    output: 'output-${cosmos.name}'
    keyVaultName: keyvault.outputs.keyVaultName
    location: location
    tags: tags
    eventHubKeyVaultSecretName: eventHub.outputs.keyVaultSecretName
    eventhubNamespaceName: '${businessArea}-${loc}-evhns-${serviceName}-${env}'
    eventhubAuthorizationListenRuleName: 'asa-${serviceName}-listen'
    eventhubName: '${businessArea}-${loc}-evh-${serviceName}-${env}'
    eventhubConsumerGroupName: 'evhcg-asa-customer-fanout-${serviceName}'
    cosmosAccountName: '${businessArea}-${loc}-cosmos-${serviceName}-${env}'
    cosmosKeyVaultSecretName: cosmos.outputs.keyVaultSecretName
    cosmosDatabaseName: '${serviceDataName}-${serviceName}'
    cosmosContainerName: 'data-${serviceName}'
    cosmosPartialKey: '/Serial'
    transformationName: 'transformation'
  }
}
