param namePrefix string
param location string

resource redisMo 'Microsoft.Cache/redis@2020-06-01' = {
  name: '${namePrefix}-redis-tEsT'
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
