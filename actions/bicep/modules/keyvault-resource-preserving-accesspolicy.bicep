param location string
param keyVaultName string
param tags object
param deploymentOperatorId string

module resourceExistsModule './resourceexists.bicep' = {
  name: 'resourceExists_${uniqueString(keyVaultName)}'
  params: {
    location: location
    resourceName: keyVaultName
    // User assigned managed identity that is used to execute the deployment script on the resource group
    // User assigned Managed Identity info: https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview
    // User assigned Managed Identity needs reader role on the resource group of the resource (See Access Policies of the resource group)
    identityPrincipalId: 'MyUserAssignedManagedIdentity'
  }
}

module keyVaultModule './keyvault-resource-using-existing-accesspolicy.bicep' = {
  name: 'keyVaultResourceUsingExistingAccessPolicies_${uniqueString(keyVaultName)}'
  params: {
    location: location
    keyVaultName: keyVaultName
    keyVaultResourceExists: resourceExistsModule.outputs.exists
    tags: tags
    deploymentOperatorId: deploymentOperatorId
  }
}

output keyVaultName string = keyVaultModule.outputs.keyVaultName
