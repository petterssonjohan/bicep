param namePrefix string
param location string
param tags object

resource redisCache 'Microsoft.Cache/redis@2020-06-01' = {
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
