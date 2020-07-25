mkdir package

dotnet publish src/*.csproj \
    --configuration Release \
    --output package

zip -r -j package.zip package/*
unzip -vl package.zip