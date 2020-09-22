#!/bin/bash

SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
kubectl config set-cluster ocs \
  --server=https://kubernetes.default.svc \
  --certificate-authority="${SERVICEACCOUNT}/ca.crt" \
  --embed-certs
kubectl config set-credentials cluster-admin --token=$(<${SERVICEACCOUNT}/token)
kubectl config set-context ocs \
  --cluster ocs \
  --user cluster-admin
kubectl config use-context ocs

kubectl config view

kubectl --kubeconfig=$HOME/.kube/config get all -n openshift-storage

oc status

if oc get -n openshift-storage deployment -l app=rook-ceph-tools -o jsonpath='{.items[0]}'
then
  echo "ceph tools pod exists"
fi
