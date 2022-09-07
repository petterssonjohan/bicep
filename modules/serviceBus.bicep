// param namePrefix string
// param location string

// resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
//   name: '${namePrefix}-service-bus'
//   location: location
//   sku: {
//     name: 'Basic'
//     tier: 'Basic'
//   }
//   properties: {
//     disableLocalAuth: falseasdasd
//     zoneRedundant: false
//   }
// }

// resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2021-06-01-preview' = {
//   parent: serviceBus
//   name: '${namePrefix}-queue'
// }

// output serviceBusId string = serviceBus.id
// output serviceBusQueueId string = serviceBusQueue.id
