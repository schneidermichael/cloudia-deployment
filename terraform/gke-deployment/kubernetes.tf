terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

data "terraform_remote_state" "gke" {
  backend = "local"

  config = {
    path = "../create-gke-cluster/terraform.tfstate"
  }
}

# Retrieve GKE cluster information
provider "google" {
  project = data.terraform_remote_state.gke.outputs.project_id
  region  = data.terraform_remote_state.gke.outputs.region
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = data.terraform_remote_state.gke.outputs.zone
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.gke.outputs.kubernetes_cluster_host
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_deployment" "cloudia-database" {
  metadata {
    name = "cloudia-database"
    labels = {
      Tier       = "data"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        Tier       = "data"
      }
    }
    strategy {}
    template {
      metadata {
        labels = {
          Tier       = "data"
        }
      }
      spec {
        container {
          env {
            name  = "POSTGRES_DB"
            value = "cloudia-db"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "postgres"
          }
          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          image = "michaelxschneider/cloudia-database:latest"
          name  = "cloudia-database"
          port {
            container_port = 5432
          }
          resources {}
        }
        restart_policy = "Always"
      }
    }
  }
}




resource "kubernetes_service" "cloudia-database" {
  metadata {
    name = "cloudia-database"
    labels = {
      Tier    = "data"
    }
  }
  spec {
    selector = {
      Tier    = "data"
    }
    port {
      name        = "5432"
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_deployment" "cloudia-backend" {
  metadata {
    name = "cloudia-backend"
    labels = {
      Tier       = "business"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        Tier       = "business"
      }
    }
    strategy {}
    template {
      metadata {
        labels = {
          Tier       = "business"
        }
      }
      spec {
        container {
          env {
            name  = "ADMIN_MAIL"
            value = "admin@admin.de"
          }
          env {
            name  = "ADMIN_PWD"
            value = "top_secret"
          }
          env {
            name  = "AWS_SIMPLE_API"
            value = "https://ec2.shop"
          }
          env {
            name  = "DATABASE_URL"
            value = "postgresql://postgres:postgres@cloudia-database:5432/cloudia-db?schema=public"
          }
          env {
            name  = "JWT_SECRET"
            value = "topsecret"
          }
          image = "michaelxschneider/cloudia-app:latest"
          name  = "cloudia-backend"
          port {
            container_port = 3000
          }
          resources {}
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "cloudia-backend" {
  metadata {
    name = "cloudia-backend"
    labels = {
      Tier    = "business"
    }
  }
  spec {
    selector = {
      Tier    = "business"
    }
    port {
      name        = "3000"
      port        = 3000
      target_port = 3000
    }
  }
}


resource "kubernetes_deployment" "cloudia-frontend" {
  metadata {
    name = "cloudia-frontend"
    labels = {
      Tier       = "presentation"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        Tier       = "presentation"
      }
    }
    strategy {}
    template {
      metadata {
        labels = {
          Tier       = "presentation"
        }
      }
      spec {
        container {
          image = "michaelxschneider/cloudia-ui:latest"
          name  = "cloudia-frontend"
          port {
            container_port = 80
          }
          resources {}
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "cloudia-frontend" {
  metadata {
    name = "cloudia-frontend"
    labels = {
      Tier    = "presentation"
    }
  }
  spec {
    selector = {
      Tier    = "presentation"
    }
    port {
      name        = "80"
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.cloudia-frontend.status.0.load_balancer.0.ingress.0.ip
}
