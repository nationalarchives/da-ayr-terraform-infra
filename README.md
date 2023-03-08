# da-ayr-terraform-infra

## Prerequisite
You will need to setup the terraform environment in AWS. The terraform environment needs an s3 bucket and an Dynamo database. This is created by running the cloudformation script in the setup folder.


This repo is for deployment of infrastructure, applications and serverless resources in AWS. This build will also check for any latest container application or serverless resources and deploy it.

* **Checking into the main branch will trigger the build**.

Below are the build and deployment pipelines that are triggers once checked into main branch on this repo


| Deployment Type.           | Resource Deployed| Gthub Action repo                                                                                  | gitaction yml file                  | resources
|----------------------------|------------------|----------------------------------------------------------------------------------------------------|-------------------------------------|-------------
| Base Infra       | Base infra        | [nationalarchives/da-ayr-github-actions](https://github.com/nationalarchives/da-ayr-github-actions)  | terraform-enviromements-action.yml  | VPC,Subnets, SG
| Application      | Application       | [nationalarchives/da-ayr-github-actions](https://github.com/nationalarchives/da-ayr-github-actions)  | docker-build-ecr-ecs-deploy-kc.yml  | Keycloak Service
| Application      | Application       | [nationalarchives/da-ayr-github-actions](https://github.com/nationalarchives/da-ayr-github-actions) | docker-build-ecr-deploy.yml         | Django Python App
| Serverless       | Lambda Functions  | [nationalarchives/da-ayr-github-actions](https://github.com/nationalarchives/da-ayr-github-actions)  | deploy-lambda.yml                   | lambda functions
