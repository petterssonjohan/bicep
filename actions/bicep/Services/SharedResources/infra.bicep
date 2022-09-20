/* INFRA BICEP FOR Passanger Count (APC) Service Project */

@description('Subscription ID in Azure')
param subscriptionId string

@description('Location for resources')
param location string = 'west europe'

@description('Tags for resources')
param tags object

@description('TenantId')
param tenantId string

@description('This is the object id of the user who will do the deployment on Azure. Can be your user id on AAD. Discover it running [az ad signed-in-user show] and get the [objectId] property.')
param deploymentOperatorId string

targetScope = 'subscription'
var businessArea = 'spt'
var loc = 'weu'
var env = tags['RUNTIME-ENVIRONMENT']

@description('Name prefix for resources')
param serviceName string = 'shared' //apc | ji | voip | nme

@description('VNET Target Resource Group')
param vnetResourceGroup string

@description('Provide unique identifier for release.')
param releaseId string = newGuid()

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${businessArea}-${loc}-rg-${serviceName}-${env}'
  location: location
}

module userAssigned '../../modules/userassignedidentity.bicep' = {
  name: 'userAssignedIdentity-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}-${loc}-identity-${serviceName}-${env}'
    location: location
    tags: tags
  }
}

var kvName = '${businessArea}-${loc}-kv-${serviceName}-${env}'
module keyVaultModule '../../modules/keyvault-resource-preserving-accesspolicy.bicep' = {
  name: 'keyVaultResourcePreservingAccessPolicies_${uniqueString(kvName)}'
  params: {
    location: location
    keyVaultName: kvName
    tags: tags
    deploymentOperatorId: deploymentOperatorId
    identityPrincipalId: userAssigned.outputs.identityPrincipalId
  }
  scope: rg
}

/* So Costly.. */
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

module appService '../../modules/appservice.bicep' = {
  scope: rg
  name: 'appService-${releaseId}'
  params: {
    name: '${businessArea}-${loc}-sp-${serviceName}-${env}'
    planSku: env == 'prod' ? 'S1' : 'F1'
    location: location
  }
}
module deviceContextFunction '../../modules/function-devicecontext.bicep' = {
  name: 'deviceContext-${releaseId}'
  scope: rg
  params: {
    name: '${businessArea}-${loc}-af-context-${serviceName}-${env}'
    appServicePlanId: appService.outputs.appServicePlanId
    location: location
    tags: tags
  }
}

module redis '../../modules/redis.bicep' = {
  name: 'redis-${releaseId}'
  scope: rg
  params: {
    location: location
    name: '${businessArea}-${loc}-redis-${serviceName}-${env}'
    tags: tags
  }
}
