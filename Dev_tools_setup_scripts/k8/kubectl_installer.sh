#!/usr/bin/env bash

snap install kubectl --classic
kubectl version --client
# kubectl cluster-info

./kubectl_configurer.sh