#!/bin/bash
set -euo pipefail

# Obtain a static link to AzCopy: curl -s -D- https://aka.ms/downloadazcopy-v10-linux | grep ^Location
AZCOPY_URL=https://azcopyvnext.azureedge.net/release20220315/azcopy_linux_amd64_10.14.1.tar.gz
AZCOPY_VERSION=10.14.1

echo "Starting to install AzCopy."
curl --output /tmp/snapshot-transfer-cli-installer/azcopy.tar.gz --fail --silent --show-error --create-dirs $AZCOPY_URL
tar -xf /tmp/snapshot-transfer-cli-installer/azcopy.tar.gz --directory /tmp/snapshot-transfer-cli-installer
mv /tmp/snapshot-transfer-cli-installer/azcopy_linux_amd64_${AZCOPY_VERSION}/azcopy /usr/local/bin/.

echo "Starting to install the snapshot-transfer-cli."
mv /snapshot-transfer-cli /usr/local/bin/.
chmod a+x /usr/local/bin/azcopy

echo "Cleaning up."
rm -rf /tmp/snapshot-transfer-cli-installer

echo "Installation finished."
