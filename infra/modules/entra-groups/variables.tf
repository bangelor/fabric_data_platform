variable "environment" {
  description = "Current environment (dev, test, or prod)"
  type        = string
}

variable "business_domains" {
  description = "List of business domains for business workspaces and app audiences"
  type        = list(string)
}
