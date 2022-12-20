param(
    [Parameter()]
    [String]$paramContainerAppName,
    [String]$paramContainerAppEnvName,
    [String]$paramContainerImageName,
    [String]$paramContainerImageTag
)

$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

# ACA deploy
$rgName = $envConfig.resourceGroup
$location = $envConfig.location
$acrName = $envConfig.containerRegistryName
$useExternalIngress = $TRUE
$containerPort = 80
$acaIdentityName = $envConfig.containerAppIdentityName
$logAnalyticsWsName = $envConfig.logAnalyticsWorkspaceName
$spName = $envConfig.servicePrincipalName

Write-Host "Set config"
Write-Host "Creating RG..."

az group create --name $rgName --location $location

Write-Host "Created RG"
Write-Host "Creating ACR..."

# container registry
az deployment group create --resource-group $rgName --template-file './acr.bicep' --parameters acrName=$acrName

Write-Host "Created ACR"
Write-Host "Updating SP and setting role..."

# prep for Build + Push image
# guide: https://docs.microsoft.com/en-us/azure/container-instances/container-instances-github-action

# get service principal id by app name
$spId = $(az ad sp list --display-name $spName --query '[].[appId][]' --out table)[2]

# Update service principal for registry authentication (allow push/pull)
$registryId = $(az acr show --name $acrName --resource-group $rgName --query id --output tsv)

# assign push role
az role assignment create --assignee $spId --scope $registryId --role AcrPush

# register subscription to use namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ContainerInstance

Write-Host "Ready to Build + Push image"

Write-Host "Creating ACA..."

az deployment group create --resource-group $rgName --template-file './aca.bicep' --parameters acrName=$acrName containerAppName=$paramContainerAppName containerPort=$containerPort useExternalIngress=$useExternalIngress containerPort=$containerPort acaIdentityName=$acaIdentityName caEnvName=$paramContainerAppEnvName containerImage=$paramContainerImageName logAnalyticsWsName=$logAnalyticsWsName tag=$paramContainerImageTag

Write-Host "Created ACA"

# reset wd
Set-Location $origPath