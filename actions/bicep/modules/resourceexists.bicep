// Based on https://github.com/olafloogman/BicepModules/blob/main/resource-exists.bicep and https://ochzhen.com/blog/check-if-resource-exists-azure-bicep

@description('Resource name to check in current scope (resource group)')
param resourceName string

@description('Resource ID of user managed identity with reader permissions in current scope')
param identityPrincipalId string

param location string
param utcValue string = utcNow()

var userAssignedIdentity = resourceId(subscription().subscriptionId, resourceGroup().name, 'Microsoft.ManagedIdentity/userAssignedIdentities', '${identityPrincipalId}')

// The script below performs an 'az resource list' command to determine whether a resource exists
resource resource_exists_script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'resourceExistsDeploymentScript_${resourceName}'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.15.0'
    timeout: 'PT10M'
    scriptContent: 'result=$(az resource list --resource-group ${resourceGroup().name} --name ${resourceName}); echo $result; echo $result | jq -c \'{Result: map({name: .name})}\' > $AZ_SCRIPTS_OUTPUT_PATH;'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

//Script returns something like: //[{"name":"MyKeyVault"}]
output exists bool = length(resource_exists_script.properties.outputs.Result) > 0
