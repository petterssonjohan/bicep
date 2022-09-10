@description('Subscription ID in Azure')
param subscriptionId string

@description('storage account name')
param namePrefix string = 'st'

@description('storage account location')
param location string = 'west europe'

targetScope = 'subscription'

/* Will Create a new Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${namePrefix}-rg'
  location: location
}

/* Will Create Storage Account, Containers, Policies, Queue Service, Event Grid and EventHub */
module storageAccount 'sa/storage-account.bicep' = {
  name: 'storageAccount'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
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
  }
}

/* Will Create Redis Cache */
module redis 'redis/redis.bicep' = {
  name: 'redisCache'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

/* Will Create a Service Plan, used by for example the functions created later in this document */
module servicePlan 'serviceplan/serviceplan.bicep' = {
  name: 'servicePlan'
  scope: rg
  params: {
    location: location
    namePrefix: namePrefix
  }
}

/* Will Create VNet and Nat instances, using expected pre-existing resource group at target subscriptionId in Azure
ie; differ from other resources in the newly created resource group.  */
module network 'vnet/network.bicep' = {
  name: 'network'
  scope: resourceGroup(subscriptionId, 'dmsResourceGroup')
  params: {
    location: location
    namePrefix: namePrefix
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
  }
}
