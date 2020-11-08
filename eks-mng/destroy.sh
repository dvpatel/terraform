#!/bin/bash

kubectl delete -f web-app.yaml 
terraform destroy -auto-approve
