param namePrefix string
param location string
param hostingPlanId string

module deviceContextFunction '../../../modules/azure-function-devicecontext.bicep' = {
  name: '${namePrefix}-func-devicecontext-deploy'
  params: {
    hostingPlanId: hostingPlanId
    location: location
    namePrefix: namePrefix
  }
}

module serviceDataFunction '../../../modules/azure-function-servicedata.bicep' = {
  name: '${namePrefix}-func-servicedata-deploy'
  params: {
    hostingPlanId: hostingPlanId
    location: location
    namePrefix: namePrefix
  }
}
