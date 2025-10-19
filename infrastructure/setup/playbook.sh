#!/bin/bash

../access/scripts/setup-kubeconfig-rancher.sh ~/.kube/rancher-config-2 159.26.94.56 ../.tensordock-key.pem 22 user 6443
kubectl config use-context h100
kubectl apply -f rt.yaml
kubectl apply -f cm-slicing.yaml
kubectl apply -f plg.yaml


