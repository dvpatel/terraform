#!/bin/bash

kubectl delete -f web-app.yaml 

#  Uninstall istio
kubectl delete -f samples/addons
istioctl manifest generate --set profile=demo | kubectl delete --ignore-not-found=true -f -
kubectl delete namespace istio-system

terraform destroy -auto-approve
