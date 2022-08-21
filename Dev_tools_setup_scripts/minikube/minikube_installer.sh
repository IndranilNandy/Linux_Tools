#!/usr/bin/env bash

mkdir tmp
curl --output-dir "tmp" -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install ./tmp/minikube-linux-amd64 /usr/local/bin/minikube
rm -rf "tmp"
