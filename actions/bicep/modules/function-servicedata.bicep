// param location string
// param tags object
// param name string
// param appServicePlanId string

// resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
//   name: name
//   location: location
//   kind: 'functionapp'
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     storageAccountRequired: true
//     serverFarmId: appServicePlanId
//     siteConfig: {
//       appSettings: [
//         {
//           name: 'FUNCTIONS_WORKER_RUNTIME'
//           value: 'dotnet'
//         }
//         {
//           name: 'FUNCTIONS_EXTENSION_VERSION'
//           value: '~4'
//         }
//       ]
//       ftpsState: 'FtpsOnly'
//       minTlsVersion: '1.2'
//     }
//     httpsOnly: true
//   }
//   tags: tags
// }

// output deviceContextPrincipalId string = functionApp.identity.principalId
