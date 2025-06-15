resource "argocd_application" "subgraph" {
  metadata {
    name      = "${var.name}-subgraph"
    namespace = "argocd"
    labels = {
      app     = "${var.name}-subgraph"
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
      path            = "helm/subgraph"
      target_revision = var.branch

      helm {
        value_files = ["values.yaml", "contracts.yaml"]

        parameter {
          name  = "env.postgres.db"
          value = var.postgres_db
        }

        parameter {
          name  = "env.postgres.host"
          value = "${argocd_application.postgres.metadata[0].name}-service"
        }

        parameter {
          name  = "ingress.host"
          value = var.host_subgraph
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

