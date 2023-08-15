terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

##################################################################
# For Windows users:
# 
# Make sure you enable the "Expose daemon on tcp://localhost:2375
# without TLS" option in Docker settings and replace the docker
# provider with the below
##################################################################
#
#provider "docker" {
#  host = "tcp://127.0.0.1:2375"
#}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = var.container_name

  restart = var.restart_policy

  ports {
    internal = 80
    external = var.exposed_port
  }
}
