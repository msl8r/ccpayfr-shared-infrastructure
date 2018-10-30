module "servicebus-namespace" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace.git"
  name                = "${var.product}-servicebus-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

module "queue" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue.git"
  name                = "payment-callbacks"
  namespace_name      = "${module.servicebus-namespace.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

output "queue_primary_listen_connection_string" {
  value = "${module.queue.primary_listen_connection_string}"
}

output "queue_primary_send_connection_string" {
  value = "${module.queue.primary_send_connection_string}"
}