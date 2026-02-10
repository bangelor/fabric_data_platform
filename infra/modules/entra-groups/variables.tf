variable "environments" {
  description = "List of environments for core workspaces"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "business_domains" {
  description = "List of business domains for business workspaces and app audiences"
  type        = list(string)
}
