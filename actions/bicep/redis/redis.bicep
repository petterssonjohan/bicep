param namePrefix string
param location string
param tags object

module redisModule '../../../modules/redis.bicep' = {
  name: '${namePrefix}-redis-deploy'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
  }
}
