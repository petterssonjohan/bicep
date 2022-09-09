param namePrefix string
param location string

module subnetForDeviceContextWithNat '../../../modules/subnet.bicep' = {
  name: 'subnetDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
