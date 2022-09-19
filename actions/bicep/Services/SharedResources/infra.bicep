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
var serviceName = 'shared'

@description('VNET Target Resource Group')
param vnetResourceGroup string

@description('Provide unique identifier for release.')
param releaseId string = newGuid()

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${businessArea}-${loc}-rg-${serviceName}-${env}'
  location: location
}

module keyvault '../../modules/keyvault.bicep' = {
  name: 'kv-${releaseId}'
  scope: rg
  params: {
    tenantId: tenantId
    location: location
    serviceName: serviceName
    tags: tags
    deploymentOperatorId: deploymentOperatorId
  }
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
