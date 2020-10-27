# terraform
Terraform Examples


eks-base:
	- VPC with public and private subnets
	- NAT G/W
	- Bastion host
	- user-data.sh;  scripts to install dependent modules;  clones eks-mng repot; script to build cluster

eks-mng:
	- Builds private EKS in private subnet
        - Used by user-data.sh script in eks-base project


To start from eks-base:
1.  cd eks-base
2.  update variables.tf file
3.  Override other inputs:  vpc_name, vpc_cidr, etc.;  See modules/*/variables.tf
4.  create / edit user-data.sh
5.  terraform init / plan / apply


To start from eks-mng:
1.  Dependency, make sure eks-base is executed
2.  SSH into bastion host created from eks-base
3.  Configure aws 
4.  Install dependent tools:  git, terraform
5.  git clone eks-mng from github
6.  cd terraform/eks-mng
7.  edit variable.tf to match values in eks-base/variable.tf for vpc_name and cluster_name
8.  review modulues/dig_eks/variable.tf;  Override additional vars in variable.tf where applicable
9.  terraform init / plan / apply
10. Cluster built;  
11. kubeconfig...
