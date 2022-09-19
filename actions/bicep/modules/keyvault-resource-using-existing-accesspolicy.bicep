param location string
param deploymentOperatorId string = 'asdasd'
param keyVaultName string
param keyVaultResourceExists bool
param tags object

resource existingKeyVaultResource 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (keyVaultResourceExists) {
  name: keyVaultName
}

module keyVaultModule './keyvault.bicep' = {
  name: 'KeyVaultResource_${uniqueString(keyVaultName)}'
  params: {
    tags: tags
    location: location
    keyVaultName: keyVaultName
    accessPolicies: keyVaultResourceExists ? existingKeyVaultResource.properties.accessPolicies : [
      {
        objectId: deploymentOperatorId
        tenantId: subscription().tenantId
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
  }
  dependsOn: [
    existingKeyVaultResource
  ]
}
