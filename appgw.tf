data "azurerm_key_vault_secret" "fees_register-cert" {
  name = "${var.fees_register_external_cert_name}"
  vault_uri = "${var.fees_register_external_cert_vault_uri}"
}

locals {
  fees_register_cert_suffix = "${var.env != "prod" ? "-fees_register" : ""}"
}

//APPLICATION GATEWAY RESOURCE FOR ENV=A
module "appGwSouth" {
  source = "git@github.com:hmcts/cnp-module-waf?ref=stripDownWf"
  env = "${var.env}"
  subscription = "${var.subscription}"
  location = "${var.location}"
  wafName = "${var.product}"
  resourcegroupname = "${azurerm_resource_group.rg.name}"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name = "internalNetwork"
      subnetId = "${data.azurerm_subnet.subnet_a.id}"
    },
  ]

  sslCertificates = [
    {
      name = "${var.fees_register_external_cert_name}${local.fees_register_cert_suffix}"
      data = "${data.azurerm_key_vault_secret.fees_register-cert.value}"
      password = ""
    }
  ]

  # Http Listeners
  httpListeners = [
    # fees_register
    {
      name = "fees_register-http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort80"
      Protocol = "Http"
      SslCertificate = ""
      hostName = "${var.fees_register_external_hostname}"
    },
    {
      name = "fees_register-https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort = "frontendPort443"
      Protocol = "Https"
      SslCertificate = "${var.fees_register_external_cert_name}${local.fees_register_cert_suffix}"
      hostName = "${var.fees_register_external_hostname}"
    }
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}"

      backendAddresses = [
        {
          fqdn = "${var.ilbIp}"
        },
      ]
    },
  ]

  backendHttpSettingsCollection = [
    {
      name = "backend-80"
      port = 80
      Protocol = "Http"
      CookieBasedAffinity = "Disabled"
      AuthenticationCertificates = ""
      probeEnabled = "True"
      probe = "fees_register-http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName = "${var.fees_register_external_hostname}"
    },
    {
      name = "backend-443"
      port = 443
      Protocol = "Https"
      CookieBasedAffinity = "Disabled"
      AuthenticationCertificates = "ilbCert"
      probeEnabled = "True"
      probe = "fees_register-https-probe"
      PickHostNameFromBackendAddress = "False"
      Host = "${var.fees_register_external_hostname}"

    }
  ]
  # Request routing rules
  requestRoutingRules = [
    # fees_register
    {
      name = "fees_register-http"
      RuleType = "Basic"
      httpListener = "fees_register-http-listener"
      backendAddressPool = "${var.product}-${var.env}"
      backendHttpSettings = "backend-80"
    },
    {
      name = "fees_register-https"
      RuleType = "Basic"
      httpListener = "fees_register-https-listener"
      backendAddressPool = "${var.product}-${var.env}"
      backendHttpSettings = "backend-443"
    }
  ]

  probes = [
    # fees_register
    {
      name = "fees_register-http-probe"
      protocol = "Http"
      path = "/"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-80"
      host = "${var.fees_register_external_hostname}"
      healthyStatusCodes = "200-399"
    },
    {
      name = "fees_register-https-probe"
      protocol = "Https"
      path = "/"
      interval = 30
      timeout = 30
      unhealthyThreshold = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings = "backend-443"
      host = "${var.fees_register_external_hostname}"
      healthyStatusCodes = "200-399"
    }
  ]
}
