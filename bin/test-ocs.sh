#!/bin/bash

set -e

# Set default locations if not available in the environment.
# These are configured in the Dockerfile by default.
CLUSTER_DIR="${CLUSTER_DIR:=/opt/cluster}"
CLUSTER_KUBECONFIG="${CLUSTER_DIR}/auth/kubeconfig"
OCSCI_INSTALL_DIR="${OCSCI_INSTALL_DIR:=/opt/ocs-ci}"
OUTPUT_DIR="${OUTPUT_DIR:=/test-run-results}"
CLUSTER_CONFIG="${CLUSTER_CONFIG:=${OCSCI_INSTALL_DIR}/conf/ocsci/openshift_dedicated.yaml}"

# Location of the junit output file.
JUNIT_XML="${OUTPUT_DIR}/junit.xml"

# Debug output to stdout to be captured into artifacts by the harness.
echo "### Setup script variables."
echo "- OCSCI_INSTALL_DIR: $OCSCI_INSTALL_DIR"
echo "- CLUSTER_DIR: $CLUSTER_DIR"
echo "- CLUSTER_KUBECONFIG: $CLUSTER_KUBECONFIG"
echo "- JUNIT_XML: $JUNIT_XML"
echo "- CLUSTER_CONFIG: $CLUSTER_CONFIG"
echo

# Create kubeconfig.
echo "### Setting up kubeconfig."
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
echo -n "- " && \
  kubectl config set-cluster ocs-test \
    --server=https://kubernetes.default.svc \
    --certificate-authority="${SERVICEACCOUNT}/ca.crt" \
    --embed-certs
echo -n "- " && \
  kubectl config set-credentials cluster-admin --token=$(<${SERVICEACCOUNT}/token)
echo -n "- " && \
  kubectl config set-context ocs-test \
    --cluster ocs-test \
    --user cluster-admin
echo -n "- " && \
  kubectl config use-context ocs-test

export KUBECONFIG="${HOME}/.kube/config"
KUBE_CLUSTER_NAME="ocs-test"

# Debug output to stdout to be captured into artifacts by the harness.
echo "### kubeconfig content in '$KUBECONFIG'."
echo
cat "$KUBECONFIG"
echo

# Copy kubeconfig to cluster directory.
echo "### Setting up the cluster directory."
echo
echo -n "- " && mkdir -pv "${CLUSTER_DIR}"/{auth,logs}
echo -n "- " && cp -v "$KUBECONFIG" "$CLUSTER_KUBECONFIG"
echo

# Check if oc is working.
echo '### Checking `oc status`.'
oc status
echo

echo "### Running run-ci."
cd "$OCSCI_INSTALL_DIR"
source venv/bin/activate
run-ci -m acceptance \
  --cluster-name "$KUBE_CLUSTER_NAME" \
  --cluster-path "$CLUSTER_DIR" \
  --ocsci-conf "$CLUSTER_CONFIG" \
  --junit-xml "$JUNIT_XML"

