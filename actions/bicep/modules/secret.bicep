param keyVaultName string
param secretName string

param secretValue string

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}

output keyVaultSecretName string = keyVaultSecret.name
