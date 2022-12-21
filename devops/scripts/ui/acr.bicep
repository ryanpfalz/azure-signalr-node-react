// container registry
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

param acaIdentityName string
// from https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// var acrPullGuid = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

resource acaIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: acaIdentityName
  location: location
}

// resource role_assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(subscription().id, acrPullGuid)
//   properties: {
//     principalId: acaIdentity.properties.principalId
//     roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullGuid) //AcrPull
//   }
// }

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer
