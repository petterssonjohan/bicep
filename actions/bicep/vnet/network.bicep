param namePrefix string
param location string

module subnetForDeviceContextWithNat '../../../modules/subnet.bicep' = {
  name: '${namePrefix}-subnet-deploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
