#!/bin/bash

#!/bin/bash

#Get values from parameter store and generate backend-config.auto.tfvars and terraform.tf vars

sudo apt-get install jq -y
cd terraform/environment/dev

TF_VARS=$(aws ssm get-parameter --name "terraform-tfvars" --region eu-west-2 | jq .Parameter.Value | sed -r 's/["]+//g' | sed "s/'/\"/g" )
echo $TF_VARS > terraform.tfvars

TF_AUTO_VARS=$(aws ssm get-parameter --name "backend-config-auto-tfvars" --region eu-west-2 | jq .Parameter.Value | sed -r 's/["]+//g' | sed "s/'/\"/g" )
echo $TF_AUTO_VARS > backend-config.auto.tfvars