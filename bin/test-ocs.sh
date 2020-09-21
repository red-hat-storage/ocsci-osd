#!/bin/bash

set -e

# Set default locations if not available in the environment.
# These are configured in the Dockerfile by default.
CLUSTER_DIR="${CLUSTER_DIR:=/opt/cluster}"
OCSCI_INSTALL_DIR="${OCSCI_INSTALL_DIR:=/opt/ocs-ci}"
OUTPUT_DIR="${OUTPUT_DIR:=/test-run-results}"
TOOLBOX_POD_YAML="${TOOLBOX_POD_YAML:=$OCSCI_INSTALL_DIR/ocs_ci/templates/ocs-deployment/toolbox_pod.yaml}"

# Determine the current cluster name to supply to run-ci.
KUBE_CURRENT_CONTEXT=$(kubectl config current-context)
KUBE_CLUSTER_NAME=$(\
  kubectl config view \
  -o jsonpath="{.contexts[?(@.name == \"${KUBE_CURRENT_CONTEXT}\")].context.cluster}"\
)

# Location of the junit output file.
JUNIT_XML="${OUTPUT_DIR}/junit.xml"

# Create the ceph tools pod.
kubectl create -f "$TOOLBOX_POD_YAML"
sleep 5

cd "$OCSCI_INSTALL_DIR"
source venv/bin/activate
run-ci -m tier1 \
  --cluster-name "$KUBE_CLUSTER_NAME" \
  --cluster-path "$CLUSTER_DIR" \
  --junit-xml "$JUNIT_XML"

