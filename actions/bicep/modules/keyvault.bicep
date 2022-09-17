param serviceName string
param location string
param tags object
param tenantId string

param objectId string = 'ec9a1988-988d-48bd-a1cb-76dce9535900' // github-az-bicep-spn
//param objectId string = 'c8419fb8-d4e0-4a28-9600-61dcb1c0bdae' //Should not be used, maybe should create a deploy user in script.

//added github-az-bicep-spn to key vault under IAM as owner. Then it worked..

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
    enableRbacAuthorization: true //false
    accessPolicies: [
      {
        objectId: objectId //for my user
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
    enabledForDeployment: true // VMs can retrieve certificates
    enabledForTemplateDeployment: true // ARM can retrieve values
    enablePurgeProtection: true // Not allowing to purge key vault or its objects after deletion
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    createMode: 'default'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}
//
var roleIdMapping = {
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Certificates Officer': 'a4417e6f-fecd-4de8-b567-7b0420556985'
  'Key Vault Crypto Officer': '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  'Key Vault Crypto Service Encryption User': 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
  'Key Vault Crypto User': '12338af0-0e69-4776-bea7-57ae8d297424'
  'Key Vault Reader': '21090545-7ca7-4776-b22c-e363652d74d2'
  'Key Vault Secrets Officer': 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Full Owner': '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
}
@description('Specifies the role the user will get with the secret in the vault. Valid values are: Key Vault Administrator, Key Vault Certificates Officer, Key Vault Crypto Officer, Key Vault Crypto Service Encryption User, Key Vault Crypto User, Key Vault Reader, Key Vault Secrets Officer, Key Vault Secrets User.')
@allowed([
  'Key Vault Administrator'
  'Key Vault Certificates Officer'
  'Key Vault Crypto Officer'
  'Key Vault Crypto Service Encryption User'
  'Key Vault Crypto User'
  'Key Vault Reader'
  'Key Vault Secrets Officer'
  'Key Vault Secrets User'
  'Full Owner'
])
param roleName string = 'Full Owner'

resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleIdMapping[roleName], objectId, keyVault.id)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleIdMapping[roleName])
    principalId: objectId
    principalType: 'ServicePrincipal'
  }
}

output keyVaultName string = keyVault.name
////
