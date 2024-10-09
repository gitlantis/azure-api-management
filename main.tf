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
  name                  = "api_management_api_${var.resource_group.name}"
  resource_group_name   = azurerm_resource_group.rg.name
  api_management_name   = azurerm_api_management.api_management.name
  revision              = "1"
  display_name          = "API to External Service"
  path                  = ""
  protocols             = ["https"]
  subscription_required = false
}

resource "azurerm_api_management_api_operation" "get_operation" {
  operation_id        = "GetObject"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get object info"
  method              = "GET"
  url_template        = "/getobj/{id}"

  template_parameter {
    name        = "id"
    required    = true
    type        = "string"
    description = "user GUId"
  }

  response {
    status_code = 200
    description = "Successful response from external service"
  }
}

resource "azurerm_api_management_api_operation" "post_operation" {
  operation_id        = "SetObject"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Set object info from github"
  method              = "POST"
  url_template        = "/setobj"

  request {
    description = "object set rquest"
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
        <set-variable name="guid" value="@(context.Request.MatchedParameters["id"])" />

        <send-request mode="new" timeout="20" response-variable-name="blobdata" ignore-error="false">
            <set-url>@{
                return "${var.base_url}/objects/"+(string)context.Variables["guid"];
            }</set-url>
            <set-method>GET</set-method>
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-header name="User-Agent" exists-action="override">
                <value>Mozilla/5.0</value>
            </set-header>
        </send-request>
        
        <return-response>
            <set-status code="200" reason="OK" />
            <set-body>@($"{((IResponse)context.Variables["blobdata"]).Body.As<JObject>() }")</set-body>
        </return-response>
        <base />
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
        <set-variable name="body" value="@(context.Request.Body.As<string>(preserveContent: true))" />

        <send-request mode="new" timeout="20" response-variable-name="blobdata" ignore-error="false">
            <set-url>${var.base_url}/objects</set-url>
            <set-method>POST</set-method>
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@{
                return (string)context.Variables["body"]; 
            }</set-body>
        </send-request>

        <return-response>
            <set-status code="200" reason="OK" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@($"{((IResponse)context.Variables["blobdata"]).Body.As<JObject>() }")</set-body>
        </return-response>
        <base />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
}

