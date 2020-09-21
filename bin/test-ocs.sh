#!/bin/bash

set -e

# Set default locations if not available in the environment.
# These are configured in the Dockerfile by default.
CLUSTER_DIR="${CLUSTER_DIR:=/opt/cluster}"
OCSCI_INSTALL_DIR="${OCSCI_INSTALL_DIR:=/opt/ocs-ci}"
OUTPUT_DIR="${OUTPUT_DIR:=/test-run-results}"
TOOLBOX_POD_YAML="${TOOLBOX_POD_YAML:=$OCSCI_INSTALL_DIR/ocs_ci/templates/ocs-deployment/toolbox_pod.yaml}"

# Location of the junit output file.
JUNIT_XML="${OUTPUT_DIR}/junit.xml"

# Debug output to stdout to be captured into artifacts by the harness.
echo "### Setup script variables."
echo "- TOOLBOX_POD_YAML: $TOOLBOX_POD_YAML"
echo "- OCSCI_INSTALL_DIR: $OCSCI_INSTALL_DIR"
echo "- KUBE_CLUSTER_NAME: $KUBE_CLUSTER_NAME"
echo "- CLUSTER_DIR: $CLUSTER_DIR"
echo "- JUNIT_XML: $JUNIT_XML"
echo

# Create kubeconfig.
echo "### Setting up kubeconfig."
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
echo -n "- " && kubectl config set clusters.ocs.server https://kubernetes.default.svc
echo -n "- " && kubectl config set clusters.ocs.certificate-authority-data $(base64 -i -w 0 <"$SERVICEACCOUNT/ca.crt")
echo -n "- " && kubectl config set users.cluster-admin.client-key-data $(base64 -i -w 0 <"$SERVICEACCOUNT/token")
echo -n "- " && kubectl config set contexts.ocs.cluster ocs
echo -n "- " && kubectl config set contexts.ocs.user cluster-admin
echo -n "- " && kubectl config set current-context ocs
echo

kubectl config view --raw > /kubeconfig

export KUBECONFIG=/kubeconfig

# Debug output to stdout to be captured into artifacts by the harness.
echo "### kubeconfig content in '$KUBECONFIG'."
echo
cat "$KUBECONFIG"
echo

# Create the ceph tools pod.
echo "### Creating the ceph tools pod."
kubectl create -f "$TOOLBOX_POD_YAML"
echo
sleep 5

echo "### Running run-ci."
cd "$OCSCI_INSTALL_DIR"
source venv/bin/activate
run-ci -m tier1 \
  --cluster-name "$KUBE_CLUSTER_NAME" \
  --cluster-path "$CLUSTER_DIR" \
  --junit-xml "$JUNIT_XML"

