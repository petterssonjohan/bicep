param namePrefix string
param location string

param dmsResourceGroup string
param dmsSubscriptionID string

module redisModule '../../../modules/redis.bicep' = {
  name: 'redisDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

module servicePlanModule '../../../modules/serviceplan.bicep' = {
  name: 'servicePlanDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}

module subnetForDeviceContextWithNat '../../../modules/subnet.bicep' = {
  name: 'subnetDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
  scope: resourceGroup(dmsSubscriptionID, dmsResourceGroup)
}

module deviceContextFunction '../../../modules/azure-function-devicecontext.bicep' = {
  name: 'deviceContextFunction'
  params: {
    hostingPlanId: servicePlanModule.outputs.hostingPlanId
    location: location
    namePrefix: namePrefix
  }
  dependsOn: [ servicePlanModule ]
}

module serviceDataFunction '../../../modules/azure-function-servicedata.bicep' = {
  name: 'serviceDataFunction'
  params: {
    hostingPlanId: servicePlanModule.outputs.hostingPlanId
    location: location
    namePrefix: namePrefix
  }
  dependsOn: [ servicePlanModule ]
}
