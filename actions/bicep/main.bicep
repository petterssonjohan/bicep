@description('Subscription ID in Azure')
param subscriptionId string

@description('Name prefix for resources')
param namePrefix string = 'ctrss'

@description('Location for resources')
param location string = 'west europe'

@description('Tags for resources')
param tags object

@description('VNET Target Resource Group')
param vnetResourceGroup string

targetScope = 'subscription'

/* Will Create a new Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'spt-weu-rg-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
}

/* Will Create Storage Account, Containers, Policies, Queue Service, Event Grid and EventHub */
module storageAccount 'sa/storage-account.bicep' = {
  name: 'storageAccount'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}

/* Will Create System Topic, Event Subscription, EventHub with Access Policies and Consumer Group  */
module events 'events/events.bicep' = {
  name: 'events'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    subscriptionId: subscriptionId
    storageAccountName: storageAccount.outputs.storageAccountName
    tags: tags
  }
}

/* Will Create Redis Cache */
module redis 'redis/redis.bicep' = {
  name: 'redisCache'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}

/* Will Create a Service Plan, used by for example the functions created later in this document */
module servicePlan 'serviceplan/serviceplan.bicep' = {
  name: 'servicePlan'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}

/* Will Create VNet and Nat instances, using expected pre-existing resource group at target subscriptionId in Azure
ie; differ from other resources in the newly created resource group.  */
module network 'vnet/network.bicep' = {
  name: 'network'
  scope: resourceGroup(subscriptionId, vnetResourceGroup)
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}

/* Will Create Functions hosted by the service plan */
module functions 'functions/azure-functions.bicep' = {
  name: 'functions'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    hostingPlanId: servicePlan.outputs.hostingPlanId
    tags: tags
  }
}

module cosmosDb 'cosmos/cosmos.bicep' = {
  name: 'cosmos'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}

// module analytics 'analytics/analytics.bicep' = {
//   name: 'analytics'
//   scope: rg
//   params: {
//     location: location
//     namePrefix: namePrefix
//     tags: tags
//     eventHubAccessPolicyKey: events.outputs.EVENTHUB_ACCESS_POLICY_KEY
//   }
// }
