variable "name" {
  description = "The name of the project"
  type        = string
}

variable "namespace" {
  description = "Namespace"
  type        = string
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
  default     = "crosschain"
}

variable "branch" {
  description = "Branch to deploy"
  type        = string
  default     = "dev"
}

variable "repository" {
  description = "GitHub repository URL"
  type        = string
}

variable "host_hasura" {
  description = "The external host"
  type        = string
}

variable "host_subgraph" {
  description = "The external host"
  type        = string
}

variable "hasura_user" {
  description = "Hasura user"
  type        = string
  default     = "admin"
}
