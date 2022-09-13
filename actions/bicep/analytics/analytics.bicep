param namePrefix string
param location string
param tags object
param eventHubAccessPolicyKey string

//Create an stream analytics job
resource streamingJob 'Microsoft.StreamAnalytics/streamingjobs@2021-10-01-preview' = {
  name: 'spt-weu-asa-servicedataproc-${namePrefix}-${tags['RUNTIME-ENVIRONMENT']}'
  location: location
  properties: {
    sku: {
      name: 'Standard'
    }
    outputErrorPolicy: 'Drop'
    dataLocale: 'en-US'
  }
}

//Should not be needed to create multiple Stream Analytics Instances??. waiting with this..
