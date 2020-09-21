FROM registry.redhat.io/ubi8/ubi

# Based on https://catalog.redhat.com/software/containers/ubi8/python-38/5dde9cacbed8bd164a0af24a

# Configure k8s repository to install kubectl packages.
COPY k8s.repo /etc/yum.repos.d/k8s.repo

# Python package installation.
RUN INSTALL_PKGS="python38 python38-devel python38-setuptools python38-pip \
      libffi-devel libtool-ltdl enchant glibc-langpack-en redhat-rpm-config \
      git gcc kubectl" && \
    yum -y module enable python38:3.8 && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*' && \
    rm -rf /var/cache/yum

# Environment variables containing various file locations required by scripts.
ENV OCSCI_INSTALL_DIR=/opt/ocs-ci \
    CLUSTER_DIR=/opt/cluster \
    TOOLBOX_POD_YAML="$OCSCI_INSTALL_DIR/ocs_ci/templates/ocs-deployment/toolbox_pod.yaml" \
    OUTPUT_DIR=/test-run-results

# Copy installation and test scripts inside the container.
COPY bin/install-ocs-ci.sh /usr/local/bin/
COPY bin/test-ocs.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh

# Install ocs-ci inside the container.
RUN install-ocs-ci.sh

# Run the test suite script when the container is created.
ENTRYPOINT [ "/usr/local/bin/test-ocs.sh" ]
