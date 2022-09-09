param namePrefix string
param location string

module servicePlanModule '../../../modules/serviceplan.bicep' = {
  name: 'servicePlanDeploy'
  params: {
    namePrefix: namePrefix
    location: location
  }
}
output hostingPlanId string = servicePlanModule.outputs.hostingPlanId
