resource "azurerm_resource_group" "rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
}

resource "azurerm_api_management" "api_management" {
  name                = "api-manage-${var.resource_group.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "Gitlantis"
  publisher_email     = "asliddin_oripov@epam.com"
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_api" "api" {
  name                = "api_management_api_${var.resource_group.name}"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.api_management.name
  revision            = "1"
  display_name        = "API to External Service"
  path                = ""
  protocols           = ["https"]
}

resource "azurerm_api_management_backend" "external_backend" {
  name                = "external_service_${var.resource_group.name}"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.api_management.name
  url                 = var.base_url
  protocol            = "http"
}

resource "azurerm_api_management_api_operation" "get_operation" {
  operation_id        = "GetUser"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get user info"
  method              = "GET"
  url_template        = "/getuser/{id}"

  template_parameter {
    name        = "id"
    required    = false
    type        = "string"
    description = "user GUId"
  }

  response {
    status_code = 200
    description = "Successful response from external service"
  }
}

resource "azurerm_api_management_api_operation" "post_operation" {
  operation_id        = "login"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get JWT token for authorization"
  method              = "POST"
  url_template        = "/login"

  request {
    description = "login trquest"
    representation {
      content_type = "application/json"

    }
  }

  response {
    status_code = 200
    description = "Successfully posted data to external service"
  }
}

resource "azurerm_api_management_api_operation_policy" "get_policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.rg.name
  operation_id        = azurerm_api_management_api_operation.get_operation.operation_id

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <validate-jwt header-name="Authorization" failed-validation-httpcode="400" failed-validation-error-message="Bad Request">            
        </validate-jwt>
        <set-backend-service base-url="${var.base_url}/User/GetUser?guid={id}" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
}

resource "azurerm_api_management_api_operation_policy" "post_policy" {
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.rg.name
  operation_id        = azurerm_api_management_api_operation.post_operation.operation_id

  xml_content = <<XML
<policies>
    <inbound>
        <base />
        <set-backend-service base-url="${var.base_url}/User/Login" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
}
