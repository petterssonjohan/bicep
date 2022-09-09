param namePrefix string
param location string

module redisModule '../../../modules/redis.bicep' = {
  name: 'redisDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
