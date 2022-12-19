$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

$rgName = $envConfig.resourceGroup
$location = $envConfig.location
$signalrName = $envConfig.signalr
$storageAccount = $envConfig.storageAccountName


Write-Host "Set config"
Write-Host "Creating RG..."

# RG deploy
az group create --name $rgName --location $location

Write-Host "Created RG"

Write-Host "Creating Storage Account and SignalR..."

# storage
# az cli works well for functions
az storage account create --name $storageAccount --resource-group $rgName --sku "Standard_LRS"

# signalr
az signalr create -n $signalrName -g $rgName --sku "Free_F1"

Write-Host "Created Storage Account and Function"

# reset wd
Set-Location $origPath