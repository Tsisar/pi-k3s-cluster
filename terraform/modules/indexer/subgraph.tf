resource "argocd_application" "hasura" {
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
      repo_url        = "git@github.com:desync-labs/splyce-infrastructure.git"
      path            = "k8s/subgraph"
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
          name  = "env.ingress.host"
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

