Terraform v0.13.4
AWS Account

//----------------------------------------------------------------------------

Add secrets_variables.tf file:  
variable "cluster_arn" {
  description = "EKS Cluster ARN"
  default = "arn:aws:iam::<aws_account>:role/devEKSClusterRole"
}

variable "nodegroup_arn" {
  description = "EKS NodeGroup ARN"
  default = "arn:aws:iam::<aws_account>:role/devNodeInstanceRole"
}

run terraform init, plan, apply

//----------------------------------------------------------------------------

copy container to private registry:
https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html

sample app post eks creation:
https://docs.aws.amazon.com/eks/latest/userguide/sample-deployment.html
Need to copy nginx:1.19.2 to private registry

Runn this command to 
ecr_login="$(aws ecr get-login --no-include-email --region us-east-1)"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 723307513402.dkr.ecr.us-east-1.amazonaws.com

kubectl create secret docker-registry regcred \
  --docker-username=`echo $ecr_login | awk '{print $4}'` \
  --docker-password=`echo $ecr_login | awk '{print $6}'` \
  --docker-server=`echo $ecr_login | awk '{print $7}'`

https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-pod-that-uses-your-secret
Updat sample-service.yaml file to include regcred

