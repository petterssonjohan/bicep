param namePrefix string
param location string

module reditModule '../../../modules/redis.bicep' = {
  name: 'redisDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
