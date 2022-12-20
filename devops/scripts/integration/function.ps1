$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

$rgName = $envConfig.resourceGroup
$location = $envConfig.location
$functionName = $envConfig.functionName
$storageAccount = $envConfig.storageAccountName
# $appServicePlan = $envConfig.appServicePlan
$pythonVersion = $envConfig.functionPythonVersion

Write-Host "Set config"
Write-Host "Creating RG..."

# RG deploy
az group create --name $rgName --location $location

Write-Host "Created RG"

Write-Host "Creating Storage Account and Function..."
# functions
# az cli works well for functions
az storage account create --name $storageAccount --resource-group $rgName --sku "Standard_LRS"

# TODO: update plan used by function
# note: automatically creates app insights resource
# broadcast & negotiate will be deployed to the same resource
az functionapp create --name $functionName --resource-group $rgName --storage-account $storageAccount --os-type "Linux"  --runtime "python" --runtime-version $pythonVersion --functions-version 4 --consumption-plan-location $location # --plan $appServicePlan # 

Write-Host "Created Storage Account and Function"

# reset wd
Set-Location $origPath