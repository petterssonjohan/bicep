@description('storage account name')
param storage_account_name string = 'st${uniqueString(resourceGroup().name)}'

@description('storage account location')
param location string = 'west europe' //north eu

module storageModule '../../modules/storages.bicep' = {
  name: 'storageDeploy'
  params: {
    storage_account_name: storage_account_name
    location: location
  }
}

// @description('storage account name')
// param storage_account_name string = 'st${uniqueString(resourceGroup().name)}'

// @description('storage account location')
// param location string = 'west europe' //north eu

// //Create a storage account
// resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
//   name: storage_account_name
//   location: location
//   kind: 'StorageV2'
//   properties: {
//     minimumTlsVersion: 'TLS1_2'
//   }
//   sku: {
//     name: 'Standard_LRS'
//   }
// }

// // Create a storage blob container for service data and for device context
// var containers = [ 'servicedata', 'devicecontext' ]
// resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for container in containers: {
//   name: '${storage_account_name}/default/${container}'
//   properties: {
//     publicAccess: 'None'
//     metadata: {}
//   }
//   dependsOn: [ storageaccount ]
// }]

// //Create a lifecycle management rule for that storage account
// resource management_policies 'Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01' = {
//   name: 'default'
//   properties: {
//     policy: {
//       rules: [
//         {
//           enabled: true
//           name: 'delete-after-14-days'
//           type: 'Lifecycle'
//           definition: {
//             actions: {
//               baseBlob: {
//                 delete: {
//                   daysAfterModificationGreaterThan: 14
//                 }
//               }
//               snapshot: {
//                 delete: {
//                   daysAfterCreationGreaterThan: 14
//                 }
//               }
//             }
//             filters: {
//               blobTypes: [
//                 'blockBlob', 'appendBlob'
//               ]
//               prefixMatch: [
//                 'servicedata/'
//               ]
//             }
//           }
//         }
//       ]
//     }
//   }
//   parent: storageaccount
// }

// //Creating Storage Queue

// output result string = 'Done!'
