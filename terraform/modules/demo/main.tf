resource "kubernetes_namespace" "demo" {
  metadata {
    name = var.namespace
  }
}

resource "argocd_application" "demo" {
  metadata {
    name      = var.name
    namespace = "argocd"
  }

  spec {
    project = "default"

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.namespace
    }

    source {
      repo_url        = var.repository
      path            = "helm/demo"
      target_revision = "dev"

      helm {
        release_name = var.name
        value_files = ["values.yaml"]
        values = yamlencode({
          rollout = {
            canary = {
              steps = [
                {
                  weight = 25
                  pause  = true
                },
                {
                  weight = 50
                  pause  = true
                },
                {
                  weight = 100
                  pause  = true
                }
              ]
            }
          }
        })
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
}