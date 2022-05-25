terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "host" {
  type = string
}

variable "client_certificate" {
  type = string
}

variable "client_key" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

provider "kubernetes" {
  host = var.host

  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
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
      name        = "4200"
      port        = 4200
      target_port = 80
    }
    type = "NodePort"
  }
}
