param name string
param location string
param tags object
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: name
  location: location
  tags: tags
}
output identityPrincipalId string = uami.properties.principalId
output tenantId string = uami.properties.tenantId
