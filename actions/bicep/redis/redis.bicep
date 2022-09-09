param namePrefix string
param location string

module reditModule '../../../modules/redis.bicep' = {
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
