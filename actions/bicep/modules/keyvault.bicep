//param deploymentOperatorId // github-az-bicep-spn, Contrubutor
param location string
param tags object
param keyVaultName string
param accessPolicies array

//added github-az-bicep-spn to key vault Azure Active Directory, App Registration, github-az-bicep-spn, API permissions, Azure Key Vault user_impersonation. 
//Then it worked.., todo: Try to remove and try again

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName //keyVaultName todo: check below (1) 
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true //false
    accessPolicies: accessPolicies
    enabledForDeployment: true // VMs can retrieve certificates
    enabledForTemplateDeployment: true // ARM can retrieve values
    enablePurgeProtection: true // Not allowing to purge key vault or its objects after deletion
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    createMode: 'default'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}
output keyVaultName string = keyVault.name

//[1]
//Using uniqueString now because enablePurgeProtection could not be set to false
//So its for now.. need to be set to true, and then during testing we remove alot 
//of resources created from bicep, including key vault. But key vault have a
//restriction for deleting if purge protection is set to true, you can delete it
//but not purge it, will get deleted after 90 days or so. So
//now during testing we can expect new key vault being created without error like
//already exist and are in purge mode....
