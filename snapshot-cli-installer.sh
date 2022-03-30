#!/bin/bash
set -euo pipefail

# Obtain a static link to AzCopy: curl -s -D- https://aka.ms/downloadazcopy-v10-linux | grep ^Location
AZCOPY_URL=https://azcopyvnext.azureedge.net/release20220315/azcopy_linux_amd64_10.14.1.tar.gz
AZCOPY_VERSION=10.14.1

echo "Looking for pg_dump."
if ! command -v pg_dump > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install pg_dump on your system using your favourite package manager."
	echo ""
	echo " Restart after installing pg_dump."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for pg_restore."
if ! command -v pg_restore > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install pg_restore on your system using your favourite package manager."
	echo ""
	echo " Restart after installing pg_restore."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for psql."
if ! command -v psql > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install psql on your system using your favourite package manager."
	echo ""
	echo " Restart after installing psql."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for sed."
if ! command -v sed > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install sed on your system using your favourite package manager."
	echo ""
	echo " Restart after installing sed."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for curl."
if ! command -v curl > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " Restart after installing curl."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for tar."
if ! command -v tar > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install tar on your system using your favourite package manager."
	echo ""
	echo " Restart after installing tar."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Starting to install AzCopy."
curl --output /tmp/snapshot-cli-installer/azcopy.tar.gz --fail --silent --show-error --create-dirs $AZCOPY_URL
tar -xf /tmp/snapshot-cli-installer/azcopy.tar.gz --directory /tmp/snapshot-cli-installer
mv /tmp/snapshot-cli-installer/azcopy_linux_amd64_${AZCOPY_VERSION}/azcopy /usr/local/bin/.

echo "Starting to install the snapshot-cli."
mv /snapshot-cli /usr/local/bin/.

echo "Cleaning up."
rm -rf /tmp/snapshot-cli-installer

echo "Installation finished."
