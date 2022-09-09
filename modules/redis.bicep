param namePrefix string
param location string

resource redisCache 'Microsoft.Cache/redis@2020-06-01' = {
  name: '${namePrefix}-redis-cache'
  location: location
  tags: {
    'BUSINESS-AREA': 'SPT'
    'RUNTIME-ENVIRONMENT': 'test' //ENVIRONMENT_TYPE
  }
  properties: {
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
  }
}
