param namePrefix string
param location string
param tags object

resource redisCache 'Microsoft.Cache/redis@2022-05-01' = {
  name: 'spt-weu-redis-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
  }
}
