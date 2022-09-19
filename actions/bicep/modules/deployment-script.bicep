param name string
param location string
param tags object
param tenantId string

param deploymentOperatorId string // github-az-bicep-spn, Contrubutor

resource symbolicname 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AzureCLI'

}
