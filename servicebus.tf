module "servicebus-namespace" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace.git"
  name                = "${var.product}-servicebus-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

module "topic" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-topic.git"
  name                  = "serviceCallbackTopic"
  namespace_name        = "${module.servicebus-namespace.name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
}
  
module "subscription" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-subscription.git"
  name                  = "defaultServiceCallbackSubscription"
  namespace_name        = "${module.servicebus-namespace.name}"
  topic_name            = "${module.topic.name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
}

output "topic_primary_send_and_listen_connection_string" {
  value = "${module.topic.primary_send_and_listen_connection_string}"
}

output "psc_subscription_connection_string" {
  value = "${module.topic.primary_send_and_listen_connection_string}/subscriptions/${module.subscription.name}"
}
