#!/bin/bash
echo "update helm repo with loki"
helm repo add loki https://grafana.github.io/helm-charts
helm repo update

echo "create the namespace in AKS cluster"
kubectl create ns loki

echo "installing loki using helm"
helm install loki loki/loki-stack -f values.yaml

