param name string
param planSku string
param location string

//Describe App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: planSku
  }
}
output appServicePlanId string = appServicePlan.id

//Describe App Service?
