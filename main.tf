provider "azurerm" {
  features {}
}

locals {
  common_tags = {
    "environment"  = "${var.env}"
    "Team Name"    = "${var.team_name}"
    "Team Contact" = "${var.team_contact}"
    "Destroy Me"   = "${var.destroy_me}"
  }
  tags = merge(var.common_tags, local.common_tags)
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location
  tags = local.tags
}
