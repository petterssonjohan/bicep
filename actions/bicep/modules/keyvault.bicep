param serviceName string
param location string
param tags object
param tenantId string

resource keyVaultSecret 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${serviceName}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    enabledForTemplateDeployment: true
    tenantId: tenantId

  }
}
