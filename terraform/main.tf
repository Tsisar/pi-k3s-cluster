locals {
  current_stage = tonumber(data.external.current_stage.result.stage)

  enabled_modules = {
    ingress_nginx         = local.current_stage >= 1
    cert_manager          = local.current_stage >= 1
    redis                 = local.current_stage >= 1
    vault                 = local.current_stage >= 1
    cluster_issuer        = local.current_stage >= 2
    vault_config          = local.current_stage >= 2
    monitoring            = local.current_stage >= 2
    argo_cd               = local.current_stage >= 2
    repository_deploy_key = local.current_stage >= 2
    demo                  = local.current_stage >= 2
    indexer               = local.current_stage >= 2
  }

  hosts = {
    vault_local     = "vault.${var.domain_local}"
    vault_external  = "vault.${var.domain_external}"
    redis           = "redis.${var.domain_local}"
    redis_commander = "redis-commander.${var.domain_local}"
    prometheus      = "prometheus.${var.domain_local}"
    grafana         = "grafana.${var.domain_local}"
    argo            = "argo.${var.domain_external}"
    vault_local     = "vault.${var.domain_local}"
    vault_external  = "vault.${var.domain_external}"
    demo            = "demo.${var.domain_external}"
    postgres        = "postgres.${var.domain_local}"
    hasura          = "hasura.${var.domain_external}"
    subgraph        = "stablecoin.${var.domain_external}"
  }

}

data "external" "current_stage" {
  program = ["bash", "${path.module}/scripts/get_stage.sh"]
}

# ================= Mikrotik ==================

resource "mikrotik_dns_record" "record" {
  for_each = local.hosts

  name    = each.value
  address = "192.168.88.30"
  ttl     = 300
}

# ================= Stage-1 ====================

module "ingress_nginx" {
  source   = "./modules/ingress-nginx"
  for_each = local.enabled_modules.ingress_nginx ? { "enabled" = {} } : {}
}

module "cert_manager" {
  source   = "./modules/cert-manager"
  for_each = local.enabled_modules.cert_manager ? { "enabled" = {} } : {}
}

module "redis" {
  source         = "./modules/redis"
  for_each       = local.enabled_modules.redis ? { "enabled" = {} } : {}
  redis_host     = local.hosts.redis
  commander_host = local.hosts.redis_commander

  depends_on = [
    mikrotik_dns_record.record
  ]
}

module "vault" {
  source        = "./modules/vault-bootstrap"
  for_each      = local.enabled_modules.vault ? { "enabled" = {} } : {}
  host_local    = local.hosts.vault_local
  host_external = local.hosts.vault_external

  depends_on = [
    mikrotik_dns_record.record
  ]
}

resource "null_resource" "bump_stage_to_2" {
  provisioner "local-exec" {
    command = "jq '.stage = \"2\"' ${path.module}/scripts/stage.json > ${path.module}/scripts/stage.tmp && mv ${path.module}/scripts/stage.tmp ${path.module}/scripts/stage.json"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    module.ingress_nginx,
    module.cert_manager,
    module.redis,
    module.vault
  ]
}

# ================= Stage-2 ====================

module "cluster_issuer" {
  source   = "./modules/cluster-issuer"
  for_each = local.enabled_modules.cluster_issuer ? { "enabled" = {} } : {}
  email    = var.email
}

module "vault_config" {
  source        = "./modules/vault-config"
  for_each      = local.enabled_modules.vault_config ? { "enabled" = {} } : {}
  namespace     = module.vault["enabled"].namespace
  host_local    = local.hosts.vault_local
  host_external = local.hosts.vault_external

  depends_on = [
    module.cluster_issuer,
    module.vault
  ]
}

module "monitoring" {
  source          = "./modules/monitoring"
  for_each        = local.enabled_modules.monitoring ? { "enabled" = {} } : {}
  grafana_host    = local.hosts.grafana
  prometheus_host = local.hosts.prometheus

  depends_on = [
    module.vault_config
  ]
}

module "argo_cd" {
  source                    = "./modules/argo-cd"
  for_each                  = local.enabled_modules.argo_cd ? { "enabled" = {} } : {}
  dex_git_hub_client_id     = var.dex_git_hub_client_id
  dex_git_hub_client_secret = var.dex_git_hub_client_secret
  host                      = local.hosts.argo
  email                     = var.email

  depends_on = [
    module.vault_config
  ]
}

# resource "null_resource" "bump_stage_to_3" {
#   provisioner "local-exec" {
#     command = "jq '.stage = \"3\"' ${path.module}/scripts/stage.json > ${path.module}/scripts/stage.tmp && mv ${path.module}/scripts/stage.tmp ${path.module}/scripts/stage.json"
#   }
#
#   triggers = {
#     always_run = timestamp()
#   }
#
#   depends_on = [
#     module.cluster_issuer,
#     module.vault_config,
#     module.monitoring,
#     module.argo_cd
#   ]
# }

# ================= Stage-3 ====================

# Setting up Deploy Key in GitHub repository and connecting it to ArgoCD
module "infra" {
  source   = "./modules/infra-repository"
  for_each = local.enabled_modules.repository_deploy_key ? { "enabled" = {} } : {}
}

module "demo" {
  source     = "./modules/demo"
  for_each   = local.enabled_modules.demo ? { "enabled" = {} } : {}
  host       = local.hosts.demo
  repository = module.infra["enabled"].repository

  depends_on = [
    module.argo_cd,
    module.infra
  ]
}

# Indexer Module for Solana
module "indexer" {
  source    = "./modules/indexer"
  for_each  = local.enabled_modules.indexer ? { "enabled" = {} } : {}
  name      = "indexer"
  namespace = "indexer"
  host_hasura = local.hosts.hasura
  host_subgraph = local.hosts.subgraph
  repository = module.infra["enabled"].repository

  depends_on = [
    module.argo_cd,
    module.infra
  ]
}