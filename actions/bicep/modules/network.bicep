param location string
param publicIpAddressName string
param natGatewayName string
param vnetName string
param vnetSubnetName string

resource natGatewayIPname 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource natgateway 'Microsoft.Network/natGateways@2022-01-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: natGatewayIPname.id
      }
    ]
  }
}

/* Other Resource Group */
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.44.21.0/24'
      ]
    }
    subnets: [
      {
        name: vnetSubnetName
        properties: {
          addressPrefix: '10.44.21.0/24'
          natGateway: {
            id: natgateway.id
          }
        }
      }
    ]
  }
}
