/* ############### CREATE RESOURCE GROUP  ####################### */




@description('The name of the Azure Storage account.') 
param storageAccountName string 
  
@description('The name of the blob container.') 
var containerName = 'logs' 
  
@description('The location in which the Azure Storage resources should be deployed.') 
param location string = resourceGroup().location 
  
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-09-01' = { 
  name: storageAccountName 
  location: location 
  sku: { 
    name: 'Standard_LRS' 
  } 
  kind: 'StorageV2' 
  properties: { 
    accessTier: 'Hot' 
  } 
} 

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = { 
  name: '${storageaccount.name}/default/${containerName}' 
}
