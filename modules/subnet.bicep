param namePrefix string
param location string
param tags object

resource natGatewayIPname 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'net-publicipaddress-${namePrefix}'
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

resource natgateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: 'dms-weu-natg-${tags['RUNTIME-ENVIRONMENT']}'
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
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'dms-weu-vnet-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.44.21.0/24'
      ]
    }
    subnets: [
      {
        name: 'spt-weu-subnet-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
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
