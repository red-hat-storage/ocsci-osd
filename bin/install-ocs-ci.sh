#!/bin/bash

OCSCI_INSTALL_DIR="$OCSCI_INSTALL_DIR:=/opt/ocs-ci"
OCSCI_REPO_URL="https://github.com/red-hat-storage/ocs-ci"

git clone "$OCSCI_REPO_URL" "$INSTALL_DIR"

pushd "$INSTALL_DIR"
python3 -m venv venv
source venv/bin/activate
pip -r requirements.txt
popd

which run-ci
