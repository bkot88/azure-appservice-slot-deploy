Param(
    [Parameter(Mandatory = $True)][String]$resourceGroup,
    [Parameter(Mandatory = $True)][String]$appName,
    [Parameter(Mandatory = $True)][String]$appServiceNameOrId,
    # [Parameter(Mandatory = $True)][String]$keyVaultName,
    # [Parameter(Mandatory = $True)][String]$keyVaultResourceGroup,
    [Parameter(Mandatory = $True)][String]$packagePath,
    [String]$location = "australiasoutheast",
    [Switch]$slotDeploy = $false,
    [String]$version = "1.0.0"
)

Write-Host "Creating resource group..."
az group create --name $resourceGroup --location $location

# Set default location and rg for the script
az configure --defaults location=$location
az configure --defaults group=$resourceGroup

Write-Host "Creating app service plan..."
$doesExist = $(az appservice plan list --query "[?name=='$appServiceNameOrId'].name" -o tsv)
if ( $doesExist ) {
    Write-Host "App service plan already exists..."
} else {
    az appservice plan create --name $appServiceNameOrId --sku S1
}

# Check to see if the app exists, if so, do not run the create command
# this will desrupt the app settings which can cause outage
$doesExist = $(az webapp list --query "[?name=='$appName'].name" -o tsv)
if ( $doesExist ) {
    Write-Host "$appName already exists..."
} else {
    Write-Host "Creating a blank function app..."
    az webapp create `
        --name $appName `
        --plan $appServiceNameOrId `
        --runtime '"DOTNETCORE|3.1"'
}

Write-Host "Create a system-assigned identity..."
# https://octopus.com/blog/powershell-pipe-escaping
$principalId = $(az webapp identity assign `
    --name $appName `
    --query principalId `
    -o tsv)

# Add KeyVault Policies
# az keyvault set-policy `
#     --name $keyVaultName `
#     --resource-group $keyVaultResourceGroup `
#     --object-id  $principalId `
#     --secret-permissions get set list

if ($slotDeploy) {
    Write-Host "Creating a blank staging slot..."
    az webapp deployment slot create --name $appName --slot staging

    Write-Host "Create a staging slot system-assigned identity..."
    $principalId = $(az webapp identity assign `
        -n $appName `
        -s staging `
        --query principalId `
        -o tsv)

    # Add KeyVault Policies
    # az keyvault set-policy `
    #     --name $keyVaultName `
    #     --resource-group $keyVaultResourceGroup `
    #     --object-id  $principalId `
    #     --secret-permissions get set list

    Write-Host "Set staging slot appsettings..."
    az webapp config appsettings set `
        --name $appName `
        --slot staging `
        --settings `
            "WEBSITE_RUN_FROM_PACKAGE=1" `
            "Version=$version"

    Write-Host "Deploying app to staging slot..."
    $result = $(az webapp deployment source config-zip `
        --name $appName `
        --slot staging `
        --src $packagePath)

    if (!$result) {
        exit 1
    }

    Write-Host "Starting staging slot..."
    az webapp start --name $appName --slot staging

    Write-Host "Swapping slots..."
    az webapp deployment slot swap --name $appName --slot staging

    Write-Host "Stopping staging slot..."
    az webapp stop --name $appName --slot staging
} else {
    Write-Host "Set appsettings..."
    az webapp config appsettings set `
        --name $appName `
        --settings `
            "WEBSITE_RUN_FROM_PACKAGE=1" `
            "Version=$version"

    Write-Host "Deploying app as normal..."
    az webapp deployment source config-zip `
        --name $appName `
        --src $packagePath
}
