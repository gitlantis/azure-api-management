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

variable "publisher_email" {
  description = "publisher email from github variabeles"
  default     = ""
}

variable "publisher_name" {
  description = "publisher name from github variables"
  default     = ""
}
