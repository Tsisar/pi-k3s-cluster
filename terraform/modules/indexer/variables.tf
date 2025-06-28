variable "name" {
  description = "The name of the project"
  type        = string
  default     = "starknet-indexer"
}

variable "namespace" {
  description = "Namespace"
  type        = string
  default     = "indexer"
}

variable "type" {
  description = "Type"
  type        = string
  default     = "indexer"
}

variable "project" {
  description = "Project"
  type        = string
  default     = "indexer"
}

variable "network" {
  description = "Network"
  type        = string
  default     = "starknet"
}

variable "repository" {
  description = "GitHub repository URL"
  type        = string
}

variable "branch" {
  description = "Branch to deploy"
  type        = string
  default     = "dev"
}

variable "postgres_username" {
  description = "Postgres user"
  type        = string
  default     = "indexer"
}

variable "rpc_endpoint" {
  description = "RPC endpoint"
  type        = string
}

variable "rpc_ws_endpoint" {
  description = "RPC WS endpoint"
  type        = string
}

variable "host" {
    description = "Host for the indexer service"
    type        = string
}