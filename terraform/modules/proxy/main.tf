variable "name" {
  description = "Name of the proxy application"
  type        = string
  default     = "proxy"
}

variable "namespace" {
  description = "Namespace for the proxy application"
  type        = string
  default     = "proxy"
}

variable "type" {
  description = "Type of the application"
  type        = string
  default     = "proxy"
}

variable "project" {
  description = "Project name for the application"
  type        = string
  default     = "default"
}

variable "network" {
  description = "Network for the application"
  type        = string
  default     = "multichain"
}

variable "repository" {
  description = "Git repository URL for the proxy application"
  type        = string
}

variable "branch" {
  description = "Git branch to deploy from"
  type        = string
  default     = "dev"
}

variable "host" {
  description = "Host for the proxy application"
  type        = string
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "proxy_config" {
  metadata {
    name      = "${argocd_application.proxy.metadata[0].name}-config"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "nginx.conf" = file("${path.module}/nginx.conf")
  }
}

resource "argocd_application" "proxy" {
  metadata {
    name      = "${var.name}-proxy"
    namespace = "argocd"
    labels = {
      app     = "${var.name}-proxy"
      type    = var.type
      project = var.project
      network = var.network
    }
  }

  cascade = true

  spec {
    project = "default"

    destination {
      name      = "in-cluster"
      namespace = kubernetes_namespace.this.metadata[0].name
    }

    source {
      repo_url        = var.repository
      path            = "helm/proxy"
      target_revision = var.branch

      helm {
        value_files = ["values.yaml"]

        parameter {
          name  = "ingress.host"
          value = var.host
        }
      }
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }

  depends_on = [
    kubernetes_namespace.this
  ]
}

output "host" {
  value = var.host
}
