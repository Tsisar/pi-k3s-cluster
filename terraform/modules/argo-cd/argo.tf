locals {
  values_yaml_content = templatefile("${path.module}/values.yaml.tpl", {
    server_insecure = var.server_insecure,
    host            = "https://${var.host}",
  })
  hashed_password = bcrypt(random_password.argo_cd.result)
}

resource "random_password" "argo_cd" {
  length  = 12
  special = true
}

resource "vault_generic_secret" "argo_cd" {
  path = "secret/argo_cd"

  data_json = jsonencode({
    password = random_password.argo_cd.result
  })
}

# Create argo-cd namespace
resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = "argocd"
  }
}

# Helm release for ArgoCD
resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace = "argocd"

  # Use dynamically generated values.yaml file
  values = [local.values_yaml_content]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = local.hashed_password
  }

  set_sensitive {
    name  = "configs.secret.extra.dexGitHubClientID"
    value = var.dex_git_hub_client_id
  }

  set_sensitive {
    name  = "configs.secret.extra.dexGitHubClientSecret"
    value = var.dex_git_hub_client_secret
  }

  lifecycle {
    ignore_changes = [set_sensitive]
  }

  depends_on = [
    kubernetes_namespace.argo_cd
  ]
}

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  namespace  = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  version    = "2.39.6"

  create_namespace = true

  values = [
    <<-EOF
      controller:
        replicaCount: 1
      dashboard:
        enabled: true
    EOF
  ]
}

# Ingress resource for Argo CD with Let's Encrypt certificate
resource "kubernetes_ingress_v1" "argo_cd" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/instance" = "argocd"
    }
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/issuer"                         = "argocd-issuer"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.host
      http {
        path {
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }

    tls {
      hosts = [var.host]
      secret_name = "argocd-tls"
    }
  }

  depends_on = [
    helm_release.argo_cd
  ]
}

# Setup issuer based on cert_manager_installed
resource "kubernetes_manifest" "argocd_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "argocd-issuer"
      namespace = "argocd"
    }
    spec = {
      acme = {
        server = var.letsencrypt_server
        email  = var.email
        privateKeySecretRef = {
          name = "argocd-letsencrypt-private-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

output "host" {
  value = var.host
}

output "username" {
  value     = "admin"
}

output "password" {
  value     = random_password.argo_cd.result
  sensitive = true
}
