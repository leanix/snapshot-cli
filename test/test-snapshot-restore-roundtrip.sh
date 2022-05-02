#!/bin/bash
set -euo pipefail

docker run --name postgres-test -e POSTGRES_PASSWORD=postgres -d postgres:11.6

docker build --platform=linux/amd64 -t pf-mock ../.
kubectx aks-westeurope-test-dufourspitze
kubens snapshot-manager
STORAGE_APPLICATION_ID=$(kubectl get secret service-principal -o json | jq -r .data.application_id | base64 -d)
STORAGE_SECRET=$(kubectl get secret service-principal -o json | jq -r .data.secret | base64 -d)
STORAGE_TENANT_ID=$(kubectl get secret service-principal -o json | jq -r .data.tenant_id | base64 -d)

BLOB="test-app-1.leanix.net/00000000-0000-0000-0000-000000000000/2007-12-24T18:21Z-00000000-0000-0000-0000-000000000000/foo-service.sql"

if [[ "$(uname)" == "Darwin" ]] ; then
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

# create schema, table and row

cat setup.sql | docker exec -i postgres-test psql -U postgres


# run take-snapshot in PF like docker container
docker run --platform=linux/amd64 --link postgres-test --rm pf-mock bash -c "snapshot-cli -c 'host=postgres-test port=5432 dbname=postgres user=postgres password=postgres' -s 00000000-0000-0000-0000-000000000000 -u ${UPLOAD_URL} -d '/' take-snapshot"

# simulate data loss on source schema by dropping the whole table
docker exec  postgres-test psql -U postgres -c "drop table ws_00000000_0000_0000_0000_000000000000.factsheets;"



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
bash -c "curl ${DOWNLOAD_URL} --output snapshot.sql"

if [[ ! -f ./snapshot.sql ]] ; then
 echo "Snapshot Download failed"
 exit 1
fi
## restore to source schema

docker run --platform=linux/amd64 --link postgres-test --rm pf-mock bash -c "snapshot-cli -c 'host=postgres-test port=5432 dbname=postgres user=postgres password=postgres' -s 00000000-0000-0000-0000-000000000000 -t 00000000-0000-0000-0000-000000000000 -u ${DOWNLOAD_URL} restore-snapshot"


# run restore-snapshot in PF like docker container

# verify row exists
FIRST_SELECT=$(docker exec -i postgres-test psql -U postgres -c "select * from ws_00000000_0000_0000_0000_000000000000.factsheets;")

if [[ $FIRST_SELECT != *"00000000-0000-0000-0000-000000000001"* ]] ; then
  echo "Snapshot restore in same workspace failed"
  exit 1
fi
## restore to target schema that doesn't exist yet
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

# run restore-snapshot in PF like docker container
docker run --platform=linux/amd64 --link postgres-test --rm pf-mock bash -c "snapshot-cli -c 'host=postgres-test port=5432 dbname=postgres user=postgres password=postgres' -s 00000000-0000-0000-0000-000000000000 -t 00000000-0000-0000-0000-000000000001 -u ${DOWNLOAD_URL} restore-snapshot"

# verify row exists
SECOND_SELECT=$(docker exec -i postgres-test psql -U postgres -c "select * from ws_00000000_0000_0000_0000_000000000001.factsheets;")
if [[ $SECOND_SELECT != *"00000000-0000-0000-0000-000000000001"* ]] ; then
  echo "Snapshot restore in new workspace failed"
  exit 1
fi
docker rm -f postgres-test
