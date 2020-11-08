#!/bin/bash

terraform init

terraform apply -auto-approve

#  Sample app
#  https://www.eksworkshop.com/beginner/080_scaling/test_ca/
# kubectl apply -f web-app.yaml 
# kubectl get deployment/web-stateless -n dev
# kubectl get deployment/web-stateful -n dev

#  kubectl get nodes --show-labels --selector=lifecycle=Ec2Spot

#  kubectl get -n dev deploy,svc
#  kubectl describe ing -n dev nginx-ingress
#  kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o 'aws-load-balancer-controller[a-zA-Z0-9-]+') | grep 'dev\/nginx-ingress'

#  kubectl scale --replicas=10 deployment/web-stateless -n dev
#  kubectl get pods -n dev


#  HPA Test
#  kubectl get deployment metrics-server -n kube-system
#  kubectl autoscale deployment web-stateless --cpu-percent=50 --min=1 --max=15 -n dev
#  kubectl describe hpa -n dev
#  while true; do wget -q -O- http://internal-k8s-dev-nginxing-8dead848ea-1277375131.us-east-1.elb.amazonaws.com; done
