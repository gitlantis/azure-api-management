variable "AZ_SUBSCRIPTION_ID" {
  description = "Azure subscription ID"
  default     = ""
}
variable "AZ_CLIENT_ID" {
  description = "Azure client ID"
  default     = ""
}
variable "AZ_CLIENT_SECRET" {
  description = "Azure client secret"
  default     = ""
}
variable "AZ_TENANT_ID" {
  description = "Azure tenant ID"
  default     = ""
}

variable "ACR_NAME" {
  description = "Azure container registery"
  default     = ""
}

variable "resource_group" {
  description = "resource groupes for api management services"
  default = {
    name     = "api-test-westus1"
    location = "West US"
  }
}

variable "base_url" {
  description = "value"
  default     = "http://146.190.151.65/api"
}
