mkdir package

dotnet publish src/*.csproj \
    --configuration Release \
    --output package

echo "\nzipping..."
zip -j package.zip package/*

echo "\nlist package items..."
unzip -vl package.zip
