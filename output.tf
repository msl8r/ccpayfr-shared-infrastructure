output "vaultName" {
  value = "${module.ccpay-vault.key_vault_name}"
}

output "vaultUri" {
  value = "${module.ccpay-vault.key_vault_uri}"
}

output "app_service_plan_id" {
  value = "${module.asp.aspResourceID}"
}