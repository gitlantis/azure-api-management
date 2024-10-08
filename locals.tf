locals {
  sanitized_rg_name_dashed = lower(replace(replace(var.resource_group.name, "[^a-z0-9]", ""), "_", "-"))
  sanitized_rg_name        = replace(local.sanitized_rg_name_dashed, "-", "")
  acr_name                 = "${local.sanitized_rg_name}acr"
}
