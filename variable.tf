variable "resource_group" {
  description = "resource groupes for api management services"
  default = {
    name     = "api-test-westus1"
    location = "West US"
  }
}

variable "base_url" {
  description = "value"
  default     = "https://api.restful-api.dev"
}
