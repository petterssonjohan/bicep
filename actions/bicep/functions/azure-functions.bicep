param namePrefix string
param location string
param hostingPlanId string

module deviceContextFunction '../../../modules/azure-function-devicecontext.bicep' = {
  name: 'deviceContextFunction'
  params: {
    hostingPlanId: hostingPlanId
    location: location
    namePrefix: namePrefix
  }
}

module serviceDataFunction '../../../modules/azure-function-servicedata.bicep' = {
  name: 'serviceDataFunction'
  params: {
    hostingPlanId: hostingPlanId
    location: location
    namePrefix: namePrefix
  }
}
