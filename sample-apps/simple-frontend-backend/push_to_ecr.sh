#!/bin/sh -e

AWS_DEFAULT_REGION="us-east-1"

APP_VERSION=latest
PLATFORM="linux/amd64"
PUBLIC_REPO_ALIAS=i5e3i8t5
#PUBLIC_REPO_ALIAS=devlearnops

aws ecr-public get-login-password --region $AWS_DEFAULT_REGION \
    | docker login --username AWS \
    --password-stdin public.ecr.aws/$PUBLIC_REPO_ALIAS


################################
# Frontend module
################################
APP_NAME=tutorials-simple-app-front
echo "Building container image for ${APP_NAME}"
docker build -t $APP_NAME:$APP_VERSION \
    --platform $PLATFORM \
    --build-arg APP_MODULE=front \
    .

ECR_REPO_NAME="public.ecr.aws/${PUBLIC_REPO_ALIAS}/${APP_NAME}"

echo "Upload $APP_NAME container image to Public ECR"
docker tag $APP_NAME:$APP_VERSION $ECR_REPO_NAME:$APP_VERSION

docker push $ECR_REPO_NAME:$APP_VERSION

################################
# Backend module
################################
APP_NAME=tutorials-simple-app-back
echo "Building container image for ${APP_NAME}"
docker build -t $APP_NAME:$APP_VERSION \
    --platform $PLATFORM \
    --build-arg APP_MODULE=back \
    .

ECR_REPO_NAME="public.ecr.aws/${PUBLIC_REPO_ALIAS}/${APP_NAME}"

echo "Upload $APP_NAME container image to Public ECR"
docker tag $APP_NAME:$APP_VERSION $ECR_REPO_NAME:$APP_VERSION

docker push $ECR_REPO_NAME:$APP_VERSION
