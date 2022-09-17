param managedIdentityName string
param location string
param operatorRoleDefinitionId string

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
}

// uses the role definition created on operatorSetup.bicep and maps it to this recently created managed identity.
resource roleassignment_operator 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(operatorRoleDefinitionId, resourceGroup().id)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: operatorRoleDefinitionId
    principalId: msi.properties.principalId
  }
}

output principalId string = msi.properties.principalId
output clientId string = msi.properties.clientId
output id string = msi.id
