#!/bin/bash
set -euo pipefail

STORAGE_ACCOUNT_KEY=$(kubectl get secret storage -o json | jq -r .data.azurestorageaccountkey | base64 -d)
STORAGE_CONNECTION_STRING=$(kubectl get secret storage -o json | jq -r .data.azurestorageconnectionstring | base64 -d)

BLOB="test-app-hook-1.leanix.net/00000000-0000-0000-0000-000000000000/2007-12-24T18:21Z-00000000-0000-0000-0000-000000000000/foo-service"

if [[ "$(uname)" == "Darwin" ]] ; then
    EXPIRY=$(date -v+5M +"%Y-%m-%dT%H:%M:%SZ")
else
    EXPIRY=$(date -d '5 mins' +"%Y-%m-%dT%H:%M:%SZ")
fi

# SAS token with write access
UPLOAD_URL=$(docker run --rm mcr.microsoft.com/azure-cli az storage blob generate-sas \
    --account-name smwesteuropetest \
    --account-key $STORAGE_ACCOUNT_KEY \
    --connection-string $STORAGE_CONNECTION_STRING \
    --container-name snapshot-manager \
    --name $BLOB \
    --permissions w \
    --expiry $EXPIRY \
    --auth-mode login \
    --as-user \
    --full-uri )

# postgres in docker

# create schema, table and row

# run take-snapshot in PF like docker container

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
