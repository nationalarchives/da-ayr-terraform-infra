# da-ayr-terraform-infra
First step is to run the tf_state_cloudformation.yml on aws to generate resources to run terraform

run the file here sh local/gen-da-ayr.sh to get credentials you need to export.

terraform init -backend-config=backend-config.auto.tfvars -upgrade -reconfigure


