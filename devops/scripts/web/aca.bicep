// ACA
param location string = resourceGroup().location
param acrName string
param containerAppName string
param useExternalIngress bool
param containerPort int
param acaIdentityId string
param caEnvName string
param containerImage string
param logAnalyticsWsName string
param tag string

// from https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// var acrPullGuid = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

var imageConcat = '${acrName}.azurecr.io/${containerImage}:${tag}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWsName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: caEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${acaIdentityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Multiple'

      registries: [
        {
          server: '${acrName}.azurecr.io'
          identity: acaIdentityId
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
      }
    }
    template: {
      containers: [
        {
          image: imageConcat
          name: containerImage
          command: [
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}
