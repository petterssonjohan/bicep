// =========== main.bicep ===========
targetScope = 'subscription'

@description('The name of the Resource Group.') 
param resourceGroupName string 

@description('The location of the Resource Group.') 
param resourceGroupLocation string 

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: 'northeurope'
}
