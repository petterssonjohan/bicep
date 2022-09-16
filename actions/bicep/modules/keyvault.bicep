param serviceName string
param location string
param tags object
param tenantId string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${serviceName}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: false //false
    accessPolicies: [
      {
        objectId: 'c8419fb8-d4e0-4a28-9600-61dcb1c0bdae' //for my user
        tenantId: tenantId
        permissions: {
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
        }
      }
    ]
    enabledForDeployment: true // VMs can retrieve certificates
    enabledForTemplateDeployment: true // ARM can retrieve values
    enablePurgeProtection: true // Not allowing to purge key vault or its objects after deletion
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    createMode: 'default'
  }
}

output keyVaultName string = keyVault.name
