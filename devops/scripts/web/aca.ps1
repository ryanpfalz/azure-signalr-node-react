param(
    [Parameter()]
    [String]$paramContainerAppName,
    [String]$paramContainerAppEnvName,
    [String]$paramContainerImageName,
    [String]$paramContainerImageTag,
    [Bool]$paramBuildInitialImage
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
$containerAppName = $envConfig.webAppContainerAppName
$containerAppEnvName = $envConfig.webAppContainerAppEnvName
$imageName = $envConfig.webAppContainerImageName

Write-Host "Set config"
Write-Host "Creating RG..."

az group create --name $rgName --location $location

Write-Host "Created RG"
Write-Host "Creating ACR..."

# container registry + managed identity
az deployment group create --resource-group $rgName --template-file './acr.bicep' --parameters acrName=$acrName acaIdentityName=$acaIdentityName 

Write-Host "Created ACR"
Write-Host "Updating SP and setting role..."

# prep for Build + Push image - set role assignments
# guide: https://docs.microsoft.com/en-us/azure/container-instances/container-instances-github-action

# get service principal id by app name
$spId = $(az ad sp list --display-name $spName --query '[].[appId][]' --out tsv)

# Update service principal for registry authentication (allow push/pull)
# assign push role to registry
$registryId = $(az acr show --name $acrName --resource-group $rgName --query id --output tsv)
az role assignment create --assignee $spId --scope $registryId --role AcrPush

# assign pull role to resource group
$miPrincipalId = $(az identity show --name $acaIdentityName --resource-group $rgName --query principalId --output tsv) # guid
$miResourceId = $(az identity show --name $acaIdentityName --resource-group $rgName --query id --output tsv) # fully qualified path
az role assignment create --assignee $miPrincipalId --resource-group $rgName --role AcrPull

# register subscription to use namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ContainerInstance

Write-Host "Ready to Build + Push image"
Write-Host "Creating ACA..."

if ($paramBuildInitialImage) {

    # To deploy a container app, you must specify a container, so build and push an initial one (it wont work since env vars arent set yet)
    $preBuildPath = Get-Location
    $preBuildPath = $preBuildPath.Path
    Set-Location "../../../ui"

    # build the image
    $tag = "v1"
    $imageNameNoTag = $acrName + ".azurecr.io/" + $imageName
    $imageNameTag = $imageNameNoTag + ":" + $tag
    docker build -t $imageNameTag -f "Dockerfile.prod" . 

    # push it to ACR
    az acr login --name $acrName
    docker push $imageNameTag

    Set-Location $preBuildPath

    az deployment group create --resource-group $rgName --template-file './aca.bicep' --parameters acrName=$acrName containerAppName=$containerAppName containerPort=$containerPort useExternalIngress=$useExternalIngress containerPort=$containerPort caEnvName=$containerAppEnvName logAnalyticsWsName=$logAnalyticsWsName containerImage=$imageName tag=$tag acaIdentityId=$miResourceId
    
}
else {
    az deployment group create --resource-group $rgName --template-file '../../bicep/ui/aca.bicep' --parameters acrName=$acrName containerAppName=$paramContainerAppName containerPort=$containerPort useExternalIngress=$useExternalIngress containerPort=$containerPort acaIdentityName=$acaIdentityName caEnvName=$paramContainerAppEnvName containerImage=$paramContainerImageName logAnalyticsWsName=$logAnalyticsWsName tag=$paramContainerImageTag acaIdentityId=$miResourceId
}

Write-Host "Created ACA"

# steps performed outside of pipeline - configure pipeline secrets: https://docs.microsoft.com/en-us/azure/container-instances/container-instances-github-action#save-credentials-to-github-repo

# reset wd
Set-Location $origPath