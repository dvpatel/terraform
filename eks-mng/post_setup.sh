#!/bin/bash

REGION="$1"
CLUSTER_NAME="$2"

aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

#  Install cert mgr
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.2/cert-manager.yaml


#  Add eks repository to helm
helm repo add eks https://aws.github.io/eks-charts


#  https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
#  alb-node-iam-policy.json
#  Set ALB Ingress, pre-req IAM Policy alb-node-iam-policy.json must be attached to eks worker nodes (devNodeInstanceRole), AWSLoadBalancerControllerIAMPolicy
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME
kubectl logs -n kube-system $(kubectl get po -n kube-system | egrep -o aws-load-balancer-controller[a-zA-Z0-9-]+)
#  kubectl -n kube-system rollout status deployment aws-load-balancer-controller


#  Setup Node Termination handler as daemonset
helm upgrade --install aws-node-termination-handler --namespace kube-system --set nodeSelector.lifecycle=Ec2Spot eks/aws-node-termination-handler
kubectl --namespace=kube-system get daemonsets 


#  Cluster Autoscaler
cat $HOME/terraform/eks-mng/cluster-autoscaler-autodiscover.yaml  | sed 's/CLUSTER_NAME/'"${CLUSTER_NAME}"'/g' > $HOME/terraform/eks-mng/my_cluster.yaml

kubectl apply -f $HOME/terraform/eks-mng/my_cluster.yaml
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

# we need to retrieve the latest docker image available for our EKS version
export K8S_VERSION=$(kubectl version --short | grep 'Server Version:' | sed 's/[^0-9.]*\([0-9.]*\).*/\1/' | cut -d. -f1,2)
export AUTOSCALER_VERSION=$(curl -s "https://api.github.com/repos/kubernetes/autoscaler/releases" | grep '"tag_name":' | sed -s 's/.*-\([0-9][0-9\.]*\).*/\1/' | grep -m1 ${K8S_VERSION})

kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v${AUTOSCALER_VERSION}
kubectl -n kube-system logs -f deployment/cluster-autoscaler


#  https://github.com/aws/eks-charts/tree/master/stable/aws-vpc-cni
#  helm install aws-vpc-cni --namespace kube-system eks/aws-vpc-cni --values eni-values.yaml


#  Setup metrics server for HPA
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.0/components.yaml


#  Install Calico
#  kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.7.5/config/v1.7/calico.yaml



#  Incomplete
#  https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
#  Make sure AmazonEKSVPCResourceController is added to eks cluster role
#  kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true

#  Todo
#  Setup custom CNI Networking
#  https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html


#  istio setup during bastion install
#  Install istio
istioctl install --set profile=default --skip-confirmation
kubectl -n istio-system get svc
kubectl -n istio-system get pods

#  Add a namespace label to instruct Istio to automatically inject Envoy sidecar 
#  proxies when you deploy your application later:
#  kubectl label namespace default istio-injection=enabled

#  Auto add envoy sidecar to dev namespace
kubectl create namespace dev
kubectl label namespace dev istio-injection=enabled
