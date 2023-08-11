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

* A new VPC with public and private subnets
* A new ECS cluster
* Two ECS services in the cluster (one to run the `front` container and another to run the `back` container)
* A public facing ALB (Application Load Balancer) to serve the front API publicly
* A private ALB to load balance the backend application
* Additional supporting resources

### Creating resources using Terraform

If you have the tutorial project checked out locally, the quickest way to deploy this application
on your own AWS account is directly from the `./infrastructure/` directory.

```shell
cd ./infrastructure

export AWS_DEFAULT_REGION=us-east-1   # or replace with your region
export AWS_PROFILE=default            # or replace with your aws profile

# initialize terraform modules
terraform init

# apply stack and specify mandatory variables using `--var`
terraform apply \
    --var environment=tutorial \
    --var application_name=sample-app

# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
# 
#   Enter a value: -> <type "yes">
```

### Creating resources using Terragrunt

If you're following another tutorial, you've likely been instructed to deploy the resources using [Terragrunt][].
Terragrunt will allow you to apply the terraform stack directly from GitHub.

Once you have [installed Terragrunt][] in your system, you'll need to create a new `terragrunt.hcl` file in any location
with the following content:

```terraform
# ./terragrunt.hcl

terraform {
  source = "git::git@github.com:DevLearnOps/tutorials//sample-apps/simple-frontend-backend/infrastructure?ref=main"
}

inputs = {
  environment = "tutorial"
  application_name  = "sample-app"
}
```

This simple Terragrunt file will automatically checkout the infrastructure code from GitHub and apply it when running
Terragrunt commands.

Using Terragrunt will also allow you to specify input variables using the `inputs = {...}` section. Feel free to modify
this section with your own variables and values. A full list of available variables can be found in the [./infrastructure/variables.tf](./infrastructure/variables.tf) file.

Now, open a shell at the same location as the `terragrunt.hcl` file you just created and run the following:

```shell
cd ./my-project-location

export AWS_DEFAULT_REGION=us-east-1   # or replace with your region
export AWS_PROFILE=default            # or replace with your aws profile

# initialize terraform modules
terragrunt init

# apply stack
terragrunt apply

# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
# 
#   Enter a value: -> <type "yes">
```

### Cleanup created resources

Depending on whether you deployed the infrastructure using **Terraform** or **Terragrunt**, to remove all created resources
from your AWS account just use the `destroy` like so:

**Using Terraform**

```shell
terraform destroy \
    --var environment=tutorial \
    --var application_name=sample-app
```

**Using Terragrunt**

```shell
terragrunt destroy
```

[Terraform]: https://www.terraform.io/
[Terragrunt]: https://terragrunt.gruntwork.io/
[installed Terragrunt]: https://terragrunt.gruntwork.io/docs/getting-started/install/

