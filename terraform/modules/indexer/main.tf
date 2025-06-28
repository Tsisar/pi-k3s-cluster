resource "argocd_application" "indexer" {
  metadata {
    name      = "${var.name}-indexer"
    namespace = "argocd"
    labels = {
      app     = "${var.name}-indexer"
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
      namespace = kubernetes_namespace.indexer.metadata[0].name
    }

    source {
      repo_url        = var.repository
      path            = "helm"
      target_revision = var.branch

      helm {
        value_files = ["values.yaml"]

        parameter {
          name  = "postgres.auth.username"
          value = var.postgres_username
        }

        parameter {
          name  = "postgres.auth.password"
          value = random_password.postgres_password.result
        }

        parameter {
          name  = "config.rpc.endpoint"
          value = var.rpc_endpoint
        }

        parameter {
          name  = "config.rpc.ws_endpoint"
          value = var.rpc_ws_endpoint
        }

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
    kubernetes_namespace.indexer
  ]
}

