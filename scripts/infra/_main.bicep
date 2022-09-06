// =========== main.bicep ===========

// Setting target scope
targetScope = 'subscription'

@description('The location of the Resource Group.')
param resourceGroupLocation string

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-contoso'
  location: resourceGroupLocation
}

// Deploying storage account using module
module stg './storage.bicep' = {
  name: 'storageDeployment'
  scope: rg // Deployed in the scope of resource group we created above
  params: {
    storageAccountName: 'stcontoso'
  }
}
