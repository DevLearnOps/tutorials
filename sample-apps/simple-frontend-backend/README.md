# Simple Frontend Backend Application

This folder contains a simple Python web application for chaos engineering testing.

## How to run the application locally

You can run this application using **Docker**:

```shell
docker compose build
docker compose up -d
```

## Using the application

This application will run two services: a `front` and a `back`. The frontend service depends on its backend to generate the *greetings* message.

```shell
curl http://localhost:8000/
# {"message":"Hello from backend service!","status":"ok"}
```

**Front endpoints**

* `http://localhost:8000/`: Generate greetings message

**Back endpoints**

* `http://localhost:8999/health`: Health endpoint for healthchecks
* `http://localhost:8999/greet`: Generate greetings message

## Fault injection

The **back** service has the following options for fault injection:

**Stop Application**

To stop the back application POST an empty message to `/_chaos/fail` backend endpoint:

```shell
curl -I http://localhost:8999/_chaos/fail
```

## How to run the application on AWS

The `./infrastructure/` folder contains [Terraform][] code to deploy this sample *frontend-backend* application on your own AWS account.
The deployment will create the following:

[Terraform]: https://www.terraform.io/

* A new VPC with public and private subnets
* A new ECS cluster
* Two ECS services in the cluster (one to run the `front` container and another to run the `back` container)
* A public facing ALB (Application Load Balancer) to serve the front API publicly
* A private ALB to load balance the backend application
* Additional supporting resources


### Creating resources using Terraform

```shell
cd ./infrastructure
export AWS_DEFAULT_REGION=us-east-1   # or replace with your region
export AWS_PROFILE=default            # or replace with your aws profile

terraform init
terraform apply --auto-approve
```

### Creating resources using Terragrunt

```terraform
# ./terragrunt.hcl

terraform {
  #source = "git::git@github.com:foo/modules.git//app?ref=v0.0.3"
  source = "./simple-frontend-backend//infrastructure"
}

inputs = {
  environment = "tutorial"
  application_name  = "sample-app"
}
```
