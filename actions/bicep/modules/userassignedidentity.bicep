param name string
param location string
param tags object
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
  tags: tags
}
output identityPrincipalId string = uami.properties.principalId
output tenantId string = uami.properties.tenantId
