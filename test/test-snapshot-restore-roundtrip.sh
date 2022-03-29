#!/bin/bash
set -euo pipefail

STORAGE_APPLICATION_ID=$(kubectl get secret service-principal -o json | jq -r .data.application_id | base64 -d)
STORAGE_SECRET=$(kubectl get secret service-principal -o json | jq -r .data.secret | base64 -d)
STORAGE_TENANT_ID=$(kubectl get secret service-principal -o json | jq -r .data.tenant_id | base64 -d)

BLOB="test-app-hook-1.leanix.net/00000000-0000-0000-0000-000000000000/2007-12-24T18:21Z-00000000-0000-0000-0000-000000000000/foo-service2.sql"

if [[ "$(uname)" == "Darwin" ]] ; then
    EXPIRY=$(date -v+5M +"%Y-%m-%dT%H:%M:%SZ")
else
    EXPIRY=$(date -d '5 mins' +"%Y-%m-%dT%H:%M:%SZ")
fi

# SAS token with write access
UPLOAD_URL=$(docker run --rm mcr.microsoft.com/azure-cli az login --service-principal --username $STORAGE_APPLICATION_ID --password $STORAGE_SECRET --tenant $STORAGE_TENANT_ID > /dev/null && az storage blob generate-sas \
    --account-name smwesteuropetest \
    --container-name snapshot-manager \
    --name $BLOB \
    --permissions w \
    --expiry $EXPIRY \
    --auth-mode login \
    --as-user \
    --full-uri )

DOWNLOAD_URL=$(docker run --rm mcr.microsoft.com/azure-cli az login --service-principal --username $STORAGE_APPLICATION_ID --password $STORAGE_SECRET --tenant $STORAGE_TENANT_ID > /dev/null && az storage blob generate-sas \
    --account-name smwesteuropetest \
    --container-name snapshot-manager \
    --name $BLOB \
    --permissions r \
    --expiry $EXPIRY \
    --auth-mode login \
    --as-user \
    --full-uri )
echo azcopy copy "./out.txt" "$UPLOAD_URL" --put-md5
echo $DOWNLOAD_URL
# postgres in docker




# create schema, table and row

cat setup.sql | docker exec -i postgres-db psql -U postgres

# run take-snapshot in PF like docker container
../snapshot-cli -c "host=localhost port=5432 dbname=postgres user=postgres password=postgres" -s "00000000-0000-0000-0000-000000000000" -u "${UPLOAD_URL}" take-snapshot
# assert file exist on Azure-Blob

# simulate data loss on source schema by dropping the whole table

## restore to source schema
# SAS token with read access

# run restore-snapshot in PF like docker container

# verify row exists

## restore to target schema that doesn't exist yet
# SAS token with read access

# run restore-snapshot in PF like docker container

# verify row exists
