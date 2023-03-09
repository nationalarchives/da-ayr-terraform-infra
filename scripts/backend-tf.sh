#!/bin/bash

echo "Start ---------------- "
pwd
# cd terraform/environments/dev

TF_VARS=$(aws ssm get-parameter --name "terraform-tfvars" --region eu-west-2 | jq .Parameter.Value | sed -r 's/["]+//g' | sed "s/'/\"/g" )
echo $TF_VARS > terraform.tfvars
# cat terraform.tfvars

TF_AUTO_VARS=$(aws ssm get-parameter --name "backend-config-auto-tfvars" --region eu-west-2 | jq .Parameter.Value | sed -r 's/["]+//g' | sed "s/'/\"/g" )
echo $TF_AUTO_VARS > backend-config.auto.tfvars
# cat backend-config.auto.tfvars

pwd
ls -alt

cat backend-config.auto.tfvars

echo "End ---------------- "

