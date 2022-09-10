param namePrefix string
param location string

module redisModule '../../../modules/redis.bicep' = {
  name: '${namePrefix}-redis-deploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
