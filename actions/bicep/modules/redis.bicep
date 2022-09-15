param location string
param tags object
param name string

resource redisCache 'Microsoft.Cache/redis@2022-05-01' = {
  name: name
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
