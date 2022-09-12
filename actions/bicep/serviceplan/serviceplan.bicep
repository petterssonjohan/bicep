param namePrefix string
param location string
param tags object

module servicePlanModule '../../../modules/serviceplan.bicep' = {
  name: '${namePrefix}-serviceplan-deploy'
  params: {
    namePrefix: namePrefix
    location: location
    tags: tags
  }
}
output hostingPlanId string = servicePlanModule.outputs.hostingPlanId
