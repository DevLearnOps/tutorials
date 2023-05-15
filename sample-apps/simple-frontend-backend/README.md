# Simple Frontend Backend Application

This folder contains a simple Python web application for chaos engineering testing.

## How to run the application

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
