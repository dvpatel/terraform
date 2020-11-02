#!/bin/bash

#  https://aws.amazon.com/blogs/compute/cost-optimization-and-resilience-eks-with-spot-instances/
#  https://github.com/kubernetes/autoscaler/blob/cluster-autoscaler-release-1.18/cluster-autoscaler/cloudprovider/aws/README.md

terraform init

terraform apply -auto-approve

aws eks --region us-east-1 update-kubeconfig --name dev-eks

#  https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
#  alb-node-iam-policy.json
#  Set ALB Ingress, pre-req IAM Policy alb-node-iam-policy.json must be attached to eks worker nodes (devNodeInstanceRole), AWSLoadBalancerControllerIAMPolicy
helm repo add eks https://aws.github.io/eks-charts
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=dev-eks


#  Setup Node Termination handler as daemonset
helm upgrade --install aws-node-termination-handler --namespace kube-system --set nodeSelector.lifecycle=Ec2Spot eks/aws-node-termination-handler
#  kubectl --namespace=kube-system get daemonsets 


#  Cluster Autoscaler
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

# we need to retrieve the latest docker image available for our EKS version
export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}
# kubectl -n kube-system logs -f deployment/cluster-autoscaler


#  Sample app
#  https://www.eksworkshop.com/beginner/080_scaling/test_ca/
kubectl apply -f web-app.yaml
kubectl get deployment/web-stateless
kubectl get deployment/web-stateful

#  kubectl get nodes --show-labels --selector=lifecycle=Ec2Spot

#  kubectl scale --replicas=10 deployment/web-stateless
#  kubectl get pods
