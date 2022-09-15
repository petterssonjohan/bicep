param location string
param serviceName string
param tags object
param blobContainers array
param roleAssignments array
param name string
param managementPolicies object

//Create a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
  sku: {
    name: 'Standard_LRS'
  }
  tags: tags
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for container in blobContainers: {
  name: '${storageAccount.name}/default/${container.name}'
  properties: {
    publicAccess: (container.enablePublicAccess) ? 'Container' : 'None'
    metadata: container.metaData
  }
}]

//Describe role assignments
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleAssignment in roleAssignments: {
  scope: storageAccount
  name: guid(storageAccount.id, roleAssignment.principalId, roleAssignment.roleId)
  properties: {
    principalId: roleAssignment.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleId)
    principalType: (contains(roleAssignment, 'principalType')) ? roleAssignment.principalType : 'ServicePrincipal'
  }
}]

//Create a lifecycle management rule for that storage account
resource management_policies 'Microsoft.Storage/storageAccounts/managementPolicies@2022-05-01' = if (any(blobContainers)) {
  name: 'default'
  properties: managementPolicies
  parent: storageAccount
}

resource storage_queues 'Microsoft.Storage/storageAccounts/queueServices@2022-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
  }
}
resource storage_queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-05-01' = {
  name: 'logs-uploaded-${serviceName}'
  parent: storage_queues
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
