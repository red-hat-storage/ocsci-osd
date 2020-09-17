FROM registry.redhat.io/ubi8/ubi

# Based on https://catalog.redhat.com/software/containers/ubi8/python-38/5dde9cacbed8bd164a0af24a

# Python package installation.
RUN INSTALL_PKGS="python38 python38-devel python38-setuptools python38-pip \
      libffi-devel libtool-ltdl enchant glibc-langpack-en redhat-rpm-config \
      git gcc" && \
    yum -y module enable python38:3.8 && \
    yum -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

# Install ocs-ci inside the container
ENV OCSCI_INSTALL_DIR=/opt/ocs-ci

COPY ./bin/install-ocs-ci.sh /usr/local/bin/install-ocs-ci.sh
RUN install-ocs-ci.sh

CMD bash