variable "domain_local" {
  description = "Domain"
  type        = string
  default     = "local"
}

variable "domain_external" {
  description = "Domain"
  type        = string
}

variable "email" {
  description = "Email"
  type        = string
  default     = "pavlo.tsisar@tattoo.courses"
}

variable "mikrotik_username" {
  description = "Mikrotik username"
  type        = string
}

variable "mikrotik_password" {
  description = "Mikrotik password"
  type        = string
}

variable "vault_address" {
  description = "Vault address"
  type        = string
}

variable "vault_token" {
  description = "Vault root token"
  type        = string
  sensitive   = true
}

variable "dex_git_hub_client_id" {
  description = "Dex GitHub client ID"
  type        = string
}

variable "dex_git_hub_client_secret" {
  description = "Dex GitHub client secret"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Token"
  type        = string
  sensitive   = true
}

variable "rpc_endpoint" {
  description = "RPC endpoint for Starknet"
  type        = string
  default     = "https://rpc.testnet.starknet.io"
}

variable "rpc_ws_endpoint" {
  description = "RPC WebSocket endpoint for Starknet"
  type        = string
  default     = "wss://rpc.testnet.starknet.io/ws"
}
