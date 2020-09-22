# ocs-ci Containers for OpenShift Dedicated E2E Test Suite

This is a repository that builds containers for [ocs-ci]. The primary purpose
for doing so was to be able to run [ocs-ci] as the [addon test suite] for
[ocs-operator] via [osde2e]. However, it should be possible to use the
containers to run the suite anywhere.

The containers are expected to run with a service account that has admin
credentials.

There's a separate [test harness repository] which contains a skeleton
golang test suite. Check that repository for details about how the
addon testing is done using osde2e in general.

Three different containers are built using this repository:

- **ocsci-osd-base**: This container is a staged build that contains the base
  image with ocs-ci installed with all its dependencies. It is built using
  (Dockerfile_base)[Dockerfile_base]. The images are available at
  https://quay.io/mkarnikredhat/ocsci-osd:base-latest
- **ocsci-osd**: This container contains the actual ocs-ci payload. It installs
  any dependencies that are not part of the "OS" and its entry point script
  runs the test suite. It is built using (Dockerfile_ocsci)[Dockerfile_ocsci]
  and the images are available at
  https://quay.io/mkarnikredhat/ocsci-osd:latest
- **osdtest**: This is a container used to test various scripts in the osde2e
  environment before building the ocsci-osd containers with those changes. It
  is built using (Dockerfile_osdtest)[Dockerfile_osdtest] and the images are
  available at https://quay.io/mkarnikredhat/osdtest:latest



[ocs-ci]:https://github.com/red-hat-storage/ocs-ci
[addon test suite]:https://github.com/openshift/osde2e/blob/main/docs/Addons.md
[ocs-operator]:https://github.com/openshift/ocs-operator
[osde2e]:https://github.com/openshift/osde2e
[test harness repository]:https://github.com/brainfunked/ocs-operator-test-harness
