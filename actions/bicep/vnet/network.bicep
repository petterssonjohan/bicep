param namePrefix string
param location string
param tags object
module subnetForDeviceContextWithNat '../../../modules/subnet.bicep' = {
  name: '${namePrefix}-subnet-deploy'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
  }
}
