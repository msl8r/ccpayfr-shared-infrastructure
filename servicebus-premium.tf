module "servicebus-namespace-premium" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace"
  name                = "${var.product}-servicebus-${var.env}-premium"
  location            = var.location
  env                 = var.env
  sku                 = var.sku
  common_tags         = local.tags
  resource_group_name = azurerm_resource_group.rg.name
}

module "topic-premium" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-topic"
  name                  = "serviceCallbackTopic"
  namespace_name        = module.servicebus-namespace-premium.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "queue-premium" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-queue"
  name                  = local.retry_queue
  namespace_name        = module.servicebus-namespace-premium.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "subscription-premium" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-subscription"
  name                  = local.subscription_name
  namespace_name        = module.servicebus-namespace-premium.name
  topic_name            = module.topic-premium.name
  resource_group_name   = azurerm_resource_group.rg.name
  max_delivery_count    = "1"
  forward_dead_lettered_messages_to = module.queue.name
}



resource "azurerm_key_vault_secret" "servicebus_primary_connection_string_premium" {
  name      = "sb-primary-connection-string-premium"
  value     = module.servicebus-namespace-premium.primary_send_and_listen_connection_string
  key_vault_id = data.azurerm_key_vault.ccpay_key_vault.id
}

# primary connection string for send and listen operations
output "sb_primary_send_and_listen_connection_string_premium" {
  value = module.servicebus-namespace-premium.primary_send_and_listen_connection_string
}

output "topic_primary_send_and_listen_connection_string_premium" {
  value = module.topic-premium.primary_send_and_listen_connection_string
}

output "psc_subscription_connection_string_premium" {
  value = "${module.topic-premium.primary_send_and_listen_connection_string}/subscriptions/${local.subscription_name}"
}
