#!/bin/bash
set -euo pipefail

docker build --platform=linux/amd64 -t pf-mock ../.
kubectx aks-westeurope-test-dufourspitze
kubens snapshot-manager
STORAGE_APPLICATION_ID=$(kubectl get secret service-principal -o json | jq -r .data.application_id | base64 -d)
STORAGE_SECRET=$(kubectl get secret service-principal -o json | jq -r .data.secret | base64 -d)
STORAGE_TENANT_ID=$(kubectl get secret service-principal -o json | jq -r .data.tenant_id | base64 -d)

BLOB="test-app-1.leanix.net/00000000-0000-0000-0000-000000000000/2007-12-24T18:21Z-00000000-0000-0000-0000-000000000000/foo-service.sql"

if [[ "$(uname)" == "Darwin" ]]; then
  EXPIRY=$(date -v+5M +"%Y-%m-%dT%H:%M:%SZ")
else
  EXPIRY=$(date -d '5 mins' +"%Y-%m-%dT%H:%M:%SZ")
fi

# SAS token with write access
UPLOAD_URL=$(docker run --rm --platform=linux/amd64 mcr.microsoft.com/azure-cli:2.34.0 bash -c "az login --service-principal --username $STORAGE_APPLICATION_ID --password '$STORAGE_SECRET' --tenant $STORAGE_TENANT_ID > /dev/null && az storage blob generate-sas \
    --account-name smwesteuropetest \
    --container-name snapshot-manager \
    --name $BLOB \
    --permissions w \
    --expiry $EXPIRY \
    --auth-mode login \
    --as-user \
    --full-uri ")
# postgres in docker
echo "create file"

echo "Uploading snapshot to $UPLOAD_URL"
# run take-snapshot in PF like docker container

docker run --platform=linux/amd64 --link postgres-test --rm pf-mock bash -c "touch /tmp/snapshot.json && echo 'content' >> /tmp/snapshot.json && snapshot-transfer-cli  -l snapshot.json -u ${UPLOAD_URL} -d '/tmp' upload"

# SAS token with read access
DOWNLOAD_URL=$(docker run --rm --platform=linux/amd64 mcr.microsoft.com/azure-cli:2.34.0 bash -c "az login --service-principal --username $STORAGE_APPLICATION_ID --password '$STORAGE_SECRET' --tenant $STORAGE_TENANT_ID > /dev/null && az storage blob generate-sas \
    --account-name smwesteuropetest \
    --container-name snapshot-manager \
    --name $BLOB \
    --permissions r \
    --expiry $EXPIRY \
    --auth-mode login \
    --as-user \
    --full-uri ")

# assert file exist on Azure-Blob
bash -c "curl ${DOWNLOAD_URL} --output snapshot.json"

if [[ ! -f ./snapshot.json ]]; then
  echo "Snapshot Download failed"
  exit 1
fi

## restore to source schema
docker run --platform=linux/amd64 --link postgres-test --rm pf-mock bash -c "snapshot-transfer-cli  -d '/tmp' -l snapshot.json -u ${DOWNLOAD_URL} download"
