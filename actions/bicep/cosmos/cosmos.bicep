param namePrefix string
param location string
param tags object

module cosmosAccount '../../../modules/cosmos-account.bicep' = {
  name: '${namePrefix}-cosmos-account-deploy'
  params: {
    location: location
    namePrefix: namePrefix
    tags: tags
  }
}
