#!/bin/bash

aws eks --region us-east-1 update-kubeconfig --name dev-eks

kubectl apply -f all-resources.yaml

kubectl get daemonsets --all-namespaces

kubectl apply -f cluster-autoscaler-autodiscover.yaml

kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v1.18

kubectl apply -f web-app.yaml
kubectl get deployment/web-stateless
kubectl get deployment/web-stateful

kubectl scale --replicas=5 deployment/web-stateless
kubectl get pods
