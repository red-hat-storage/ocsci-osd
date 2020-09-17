FROM registry.redhat.io/ubi8/ubi

# Based on https://catalog.redhat.com/software/containers/ubi8/python-38/5dde9cacbed8bd164a0af24a

# Python package installation.
RUN INSTALL_PKGS="python38 python38-devel python38-setuptools python38-pip git \
      libffi-devel libtool-ltdl enchant glibc-langpack-en gcc redhat-rpm-config"

    yum -y module enable python38:3.8 && \
    yum -y --setopts=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

# Install ocs-ci inside the container
ENV OCSCI_INSTALL_DIR=/opt/ocs-ci \
    PATH="$OCSCI_INSTALL_DIR/venv/bin:$PATH"

COPY ./bin/install-ocs-ci.sh /usr/local/bin/install-ocs-ci.sh
RUN install-ocs-ci.sh

CMD bash
