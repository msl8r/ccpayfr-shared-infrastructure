provider "azurerm" {
  version = "2.29.0"
  features {}
}

locals {
  local_tags_ccpay = {
    "Deployment Environment" = var.env
    "Team Name" = var.team_name
    "Team Contact" = var.team_contact
  }

  tags = merge(var.common_tags, local.local_tags_ccpay)
}

resource "azurerm_resource_group" "rg" {
  name     = join("-", [var.product, var.env])
  location = var.location
  tags = local.tags
}
