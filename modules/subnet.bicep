param namePrefix string
param location string

/* Other Resource Group */
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${namePrefix}-weu-subnet-servicedataproc-test'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.44.21.0/24'
      ]
    }
    subnets: [
      {
        name: 'dms-weu-vnet-test'
        properties: {
          addressPrefix: '10.44.21.0/24'
          natGateway: {
            id: 'dms-weu-natg-test'
          }
        }
      }
    ]
  }
}
