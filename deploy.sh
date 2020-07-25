declare rgName="dev-slot-deploy-demo"
declare location="australiasoutheast"

az group create --name $rgName --location $location
az deployment group create \
    --name example-slot-deployment \
    --resource-group $rgName \
    --template-file deployment/azure-deploy.json \
    --parameters @deployment/azure-deploy.parameters.json

sh publish.sh

# az webapp config appsettings set \
#     --resource-group $rgName \
#     --name healthportal1234 \
#     --settings WEBSITE_RUN_FROM_PACKAGE=1

# az webapp deployment source config-zip \
#     --name healthportal1234 \
#     --resource-group $rgName \
#     --src package.zip

az webapp config appsettings set \
    --resource-group $rgName \
    --name healthportal1234 \
    --slot preview \
    --settings WEBSITE_RUN_FROM_PACKAGE=1

az webapp deployment source config-zip \
    --name healthportal1234 \
    --resource-group $rgName \
    --src package.zip \
    --slot preview
