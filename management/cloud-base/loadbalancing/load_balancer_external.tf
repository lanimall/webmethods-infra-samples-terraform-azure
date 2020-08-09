################################################
################ Outputs
################################################

output "managementexternal_appgateway_public_ip" {
  value = azurerm_public_ip.managementexternal_appgateway.ip_address
}

output "managementexternal_appgateway_public_dns" {
  value = azurerm_public_ip.managementexternal_appgateway.fqdn
}

output "managementexternal_appgateway_frontend_ip_configuration_all" {
  value = azurerm_application_gateway.managementexternal_appgateway.frontend_ip_configuration.*
}

output "managementexternal_appgateway_frontend_port_all" {
  value = azurerm_application_gateway.managementexternal_appgateway.frontend_port.*
}

output "managementexternal_appgateway_backend_address_pool_all" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.*
}

output "managementexternal_appgateway_backend_http_settings_all" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_http_settings.*
}

output "managementexternal_appgateway_backend_address_pool_id_commandcentral" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.0.id
}

output "managementexternal_appgateway_backend_address_pool_id_integrationserver" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.1.id
}

output "managementexternal_appgateway_backend_address_pool_id_tnserver" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.2.id
}

output "managementexternal_appgateway_backend_address_pool_id_mws" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.3.id
}

output "managementexternal_appgateway_backend_address_pool_id_apigateway" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.4.id
}

output "managementexternal_appgateway_backend_address_pool_id_deployer" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.5.id
}

output "managementexternal_appgateway_backend_address_pool_id_jenkins" {
  value = azurerm_application_gateway.managementexternal_appgateway.backend_address_pool.6.id
}

################################################
################ load balancer
################################################

data "azurerm_user_assigned_identity" "managementexternal_appgateway" {
  name                 = module.management_common_base_security.azurerm_user_assigned_identity_mainappgateway_name
  resource_group_name  = module.management_common_base_network.data_azurerm_resource_group.name
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  managementexternal_appgateway_simple_name = "mgtext"

  managementexternal_appgateway_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name ] )
  managementexternal_appgateway_gateway_ip_configuration_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "gateway", "ipconf" ] )
  managementexternal_frontend_ip_configuration_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "fe", "ipconf" ] )
  managementexternal_appgateway_public_ip_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "pip" ] )

  managementexternal_frontend_http_port_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "fe", "http", "port" ] )
  managementexternal_frontend_https_port_name       = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "fe", "https", "port" ] )
  managementexternal_frontend_https_ssl_certificate_name         = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "ssl", "cert" ] )
  managementexternal_frontend_https_ssl_certificate_path         = var.ssl_cert_mainlb_pfx_path
  managementexternal_frontend_https_ssl_certificate_password     = var.ssl_cert_mainlb_pfx_password
  managementexternal_frontend_https_ssl_ca_path                  = var.ssl_internal_root_ca_cert_path
  managementexternal_backend_trusted_ssl_certificate_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "be", "ssl", "trustedcert" ] )

  #### Command Central specific
  commandcentral_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "fe", "http", "listeners" ] )
  commandcentral_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "fe", "https", "listeners" ] )
  commandcentral_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "redirect", "forcessl" ] )
  commandcentral_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "fe", "http", "rtrule" ] )
  commandcentral_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "fe", "https", "rtrule" ] )

  commandcentral_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "be", "settings" ] )
  commandcentral_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "be", "probe" ] )
  commandcentral_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "cce", "be", "addresspool" ] )

  #### IS Core specific
  iscore_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "fe", "http", "listeners" ] )
  iscore_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "fe", "https", "listeners" ] )
  iscore_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "redirect", "forcessl" ] )
  iscore_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "fe", "http", "rtrule" ] )
  iscore_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "fe", "https", "rtrule" ] )
  iscore_frontend_rewrite_ruleset_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "fe", "rewriteset" ] )
  iscore_frontend_rewrite_rule1_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "fe", "rewriteset", "rule1" ] )

  iscore_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "be", "settings" ] )
  iscore_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "be", "probe" ] )
  iscore_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "iscore", "be", "addresspool" ] )

  #### TN Server specific
  tnserver_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "fe", "http", "listeners" ] )
  tnserver_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "fe", "https", "listeners" ] )
  tnserver_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "redirect", "forcessl" ] )
  tnserver_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "fe", "http", "rtrule" ] )
  tnserver_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "fe", "https", "rtrule" ] )
  tnserver_frontend_rewrite_ruleset_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "fe", "rewriteset" ] )
  tnserver_frontend_rewrite_rule1_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "fe", "rewriteset", "rule1" ] )

  tnserver_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "be", "settings" ] )
  tnserver_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "be", "probe" ] )
  tnserver_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "tnserver", "be", "addresspool" ] )

  #### MWS specifics
  mws_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "http", "listeners" ] )
  mws_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "https", "listeners" ] )
  mws_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "redirect", "forcessl" ] )
  mws_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "http", "rtrule" ] )
  mws_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "https", "rtrule" ] )
  mws_frontend_rewrite_ruleset_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "rewriteset" ] )
  mws_frontend_rewrite_rule1_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "rewriteset", "rule1" ] )
  mws_frontend_rewrite_rule2_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "fe", "rewriteset", "rule2" ] )

  mws_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "be", "settings" ] )
  mws_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "be", "probe" ] )
  mws_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "mws", "be", "addresspool" ] )

  #### APIGateway specifics
  apigateway_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "fe", "http", "listeners" ] )
  apigateway_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "fe", "https", "listeners" ] )
  apigateway_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "redirect", "forcessl" ] )
  apigateway_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "fe", "http", "rtrule" ] )
  apigateway_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "fe", "https", "rtrule" ] )
  apigateway_frontend_rewrite_ruleset_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "fe", "rewriteset" ] )
  apigateway_frontend_rewrite_rule1_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "fe", "rewriteset", "rule1" ] )

  apigateway_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "be", "settings" ] )
  apigateway_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "be", "probe" ] )
  apigateway_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "apigateway", "be", "addresspool" ] )

  #### Deployer specific
  deployer_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "fe", "http", "listeners" ] )
  deployer_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "fe", "https", "listeners" ] )
  deployer_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "redirect", "forcessl" ] )
  deployer_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "fe", "http", "rtrule" ] )
  deployer_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "fe", "https", "rtrule" ] )
  deployer_frontend_rewrite_ruleset_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "fe", "rewriteset" ] )
  deployer_frontend_rewrite_rule1_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "fe", "rewriteset", "rule1" ] )

  deployer_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "be", "settings" ] )
  deployer_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "be", "probe" ] )
  deployer_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "deployer", "be", "addresspool" ] )

  #### Jenkins specific
  jenkins_frontend_http_listener_name    = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "fe", "http", "listeners" ] )
  jenkins_frontend_https_listener_name   = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "fe", "https", "listeners" ] )
  jenkins_frontend_http_request_redirect_name  = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "redirect", "forcessl" ] )
  jenkins_frontend_http_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "fe", "http", "rtrule" ] )
  jenkins_frontend_https_request_routing_rule_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "fe", "https", "rtrule" ] )
  jenkins_frontend_rewrite_ruleset_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "fe", "rewriteset" ] )
  jenkins_frontend_rewrite_rule1_name = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "fe", "rewriteset", "rule1" ] )

  jenkins_backend_http_setting_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "be", "settings" ] )
  jenkins_backend_http_probe_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "be", "probe" ] )
  jenkins_backend_address_pool_name        = join(module.global_common_base.name_delimiter, [ module.global_common_base.name_prefix_short, local.managementexternal_appgateway_simple_name, "jenkins", "be", "addresspool" ] )
}

resource "azurerm_public_ip" "managementexternal_appgateway" {
  name                  = local.managementexternal_appgateway_public_ip_name
  resource_group_name   = module.management_common_base_network.data_azurerm_resource_group.name
  location              = module.management_common_base_network.data_azurerm_resource_group.location

  # LB with SKU Standard_v2 can only reference public ip with Standard SKU.
  sku                   = "standard"

  # Public IP Standard SKUs require allocation_method to be set to Static.
  allocation_method     = "Static"
}

resource "azurerm_application_gateway" "managementexternal_appgateway" {
  name                 = local.managementexternal_appgateway_name
  resource_group_name  = module.management_common_base_network.data_azurerm_resource_group.name
  location             = module.management_common_base_network.data_azurerm_resource_group.location

  sku {
    ##SKU Tiers 'Standard_v2, WAF_v2' support KeyVaultSecretId while SKU Tiers 'Standard, WAF' support Data in Certificate
    name     = "Standard_v2"    
    tier     = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 4
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.managementexternal_appgateway.id
    ]
  }

  gateway_ip_configuration {
    name      = local.managementexternal_appgateway_gateway_ip_configuration_name
    subnet_id = module.management_common_base_network.data_azurerm_subnet_dmz.id
  }

  # trusted_root_certificate {
  #   name = local.managementexternal_backend_trusted_ssl_certificate_name
  #   data = filebase64(local.managementexternal_frontend_https_ssl_ca_path)
  # }

  # trusted_root_certificate {
  #   name = join("", [local.commandcentral_backend_ssl_certificate_name, "2"])
  #   data = filebase64("~/mydevsecrets/saggov_shared_management_azure/configs/prod/certs/ssl/cceroot.cer.pem")
  #   data = filebase64("~/mydevsecrets/saggov_shared_management_azure/configs/prod/certs/ssl/ccenew.cer.pem")
  #   #data = base64encode(data.template_file.ssl_cert_backend_cce.rendered)
  # }

  frontend_ip_configuration {
    name                 = local.managementexternal_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.managementexternal_appgateway.id
  }

  ######################################
  # NON SSL global settings
  ######################################

  frontend_port {
    name = local.managementexternal_frontend_http_port_name
    port = 80
  }

  ######################################
  # SSL global settings
  ######################################

  frontend_port {
    name = local.managementexternal_frontend_https_port_name
    port = 443
  }
  
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401"
  }

  ## this is not working...not sure why!
  # ssl_certificate {
  #   name = local.ssl_certificate_name
  #   key_vault_secret_id = "https://management.vault.usgovcloudapi.net/secrets/test/248fddc0e98b47e088c16cde6d6c686c"
  # }

  ssl_certificate {
    name = local.managementexternal_frontend_https_ssl_certificate_name
    data = filebase64(local.managementexternal_frontend_https_ssl_certificate_path)
    password = local.managementexternal_frontend_https_ssl_certificate_password
  }

  ###############################################################################################
  ###############################################################################################
  # Sites Specifics
  ###############################################################################################
  ###############################################################################################

  ################################################################
  #### command central specifics
  ################################################################

  http_listener {
    name                           = local.commandcentral_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.commandcentral_external_host_name
  }

  http_listener {
    name                           = local.commandcentral_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.commandcentral_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.commandcentral_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.commandcentral_frontend_http_listener_name
    redirect_configuration_name = local.commandcentral_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.commandcentral_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.commandcentral_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.commandcentral_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.commandcentral_frontend_https_listener_name
    backend_address_pool_name  = local.commandcentral_backend_address_pool_name
    backend_http_settings_name = local.commandcentral_backend_http_setting_name
  }
  
  ####################### backend configs
  
  backend_address_pool {
    name = local.commandcentral_backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.commandcentral_backend_http_setting_name
    probe_name            = local.commandcentral_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 8090
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true
    
    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }

    # trusted_root_certificate_names = [
    #   local.managementexternal_backend_trusted_ssl_certificate_name
    # ]
  }

  probe {
    name                  = local.commandcentral_backend_http_probe_name
    protocol              = "Http"
    path                  = "/"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "302"
      ]
    }
  }

  ################################################################
  #### integrationserver specifics
  ################################################################

  http_listener {
    name                           = local.iscore_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.iscore_external_host_name
  }

  http_listener {
    name                           = local.iscore_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.iscore_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.iscore_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.iscore_frontend_http_listener_name
    redirect_configuration_name = local.iscore_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.iscore_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.iscore_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.iscore_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.iscore_frontend_https_listener_name
    backend_address_pool_name  = local.iscore_backend_address_pool_name
    backend_http_settings_name = local.iscore_backend_http_setting_name
  }
  
  ####################### backend configs
  
  backend_address_pool {
    name = local.iscore_backend_address_pool_name
  }
  
  backend_http_settings {
    name                  = local.iscore_backend_http_setting_name
    probe_name            = local.iscore_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 5555
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true

    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }
  }

  probe {
    name                  = local.iscore_backend_http_probe_name
    protocol              = "Http"
    path                  = "/invoke/wm.server/ping"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "200"
      ]
    }
  }

  ################################################################
  #### TN Server specifics
  ################################################################

  http_listener {
    name                           = local.tnserver_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.tnserver_external_host_name
  }

  http_listener {
    name                           = local.tnserver_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.tnserver_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.tnserver_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.tnserver_frontend_http_listener_name
    redirect_configuration_name = local.tnserver_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.tnserver_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.tnserver_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.tnserver_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.tnserver_frontend_https_listener_name
    backend_address_pool_name  = local.tnserver_backend_address_pool_name
    backend_http_settings_name = local.tnserver_backend_http_setting_name
  }
  
  ####################### backend configs
  
  backend_address_pool {
    name = local.tnserver_backend_address_pool_name
  }
  
  backend_http_settings {
    name                  = local.tnserver_backend_http_setting_name
    probe_name            = local.tnserver_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 5555
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true

    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }
  }

  probe {
    name                  = local.tnserver_backend_http_probe_name
    protocol              = "Http"
    path                  = "/invoke/wm.server/ping"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "200"
      ]
    }
  }

  ################################################################
  #### MWS specifics
  ################################################################

  http_listener {
    name                           = local.mws_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.mws_external_host_name
  }

  http_listener {
    name                           = local.mws_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.mws_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.mws_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.mws_frontend_http_listener_name
    redirect_configuration_name = local.mws_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.mws_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.mws_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.mws_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.mws_frontend_https_listener_name
    backend_address_pool_name  = local.mws_backend_address_pool_name
    backend_http_settings_name = local.mws_backend_http_setting_name
    rewrite_rule_set_name      = local.mws_frontend_rewrite_ruleset_name
  }

  rewrite_rule_set {
    name                       = local.mws_frontend_rewrite_ruleset_name
    
    rewrite_rule {
      name                       = local.mws_frontend_rewrite_rule1_name
      rule_sequence              = 1

      request_header_configuration {
        header_name = "X-Forwarded-Host"
        header_value = "{var_host}"
      }

      request_header_configuration {
        header_name = "X-Forwarded-For"
        header_value = "{var_add_x_forwarded_for_proxy}"
      }
    }
    
    rewrite_rule {
      name                       = local.mws_frontend_rewrite_rule2_name
      rule_sequence              = 2
      
      condition {
        variable = "http_resp_Location"
        pattern = "(https?):\\/\\/.*:8585(.*)$"
        ignore_case = true
        negate = false
      }

      response_header_configuration {
        header_name = "Location"
        header_value = join("", ["{http_resp_Location_1}://", var.mws_external_host_name, "{http_resp_Location_2}"])
      }
    }
  }

  ####################### backend configs
  
  backend_address_pool {
    name = local.mws_backend_address_pool_name
  }
  
  backend_http_settings {
    name                  = local.mws_backend_http_setting_name
    probe_name            = local.mws_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 8585
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true

    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }
  }

  probe {
    name                  = local.mws_backend_http_probe_name
    protocol              = "Http"
    path                  = "/"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "200"
      ]
    }
  }

  ################################################################
  #### API Gateway specifics
  ################################################################

  http_listener {
    name                           = local.apigateway_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.apigateway_external_host_name
  }

  http_listener {
    name                           = local.apigateway_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.apigateway_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.apigateway_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.apigateway_frontend_http_listener_name
    redirect_configuration_name = local.apigateway_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.apigateway_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.apigateway_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.apigateway_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.apigateway_frontend_https_listener_name
    backend_address_pool_name  = local.apigateway_backend_address_pool_name
    backend_http_settings_name = local.apigateway_backend_http_setting_name
  }

  ####################### backend configs
  
  backend_address_pool {
    name = local.apigateway_backend_address_pool_name
  }
  
  backend_http_settings {
    name                  = local.apigateway_backend_http_setting_name
    probe_name            = local.apigateway_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 5555
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true

    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }
  }

  probe {
    name                  = local.apigateway_backend_http_probe_name
    protocol              = "Http"
    path                  = "/invoke/wm.server/ping"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "200"
      ]
    }
  }

  ################################################################
  #### Deployer specifics
  ################################################################

  http_listener {
    name                           = local.deployer_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.deployer_external_host_name
  }

  http_listener {
    name                           = local.deployer_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.deployer_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.deployer_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.deployer_frontend_http_listener_name
    redirect_configuration_name = local.deployer_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.deployer_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.deployer_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.deployer_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.deployer_frontend_https_listener_name
    backend_address_pool_name  = local.deployer_backend_address_pool_name
    backend_http_settings_name = local.deployer_backend_http_setting_name
    rewrite_rule_set_name      = local.deployer_frontend_rewrite_ruleset_name
  }
    
  rewrite_rule_set {
    name                       = local.deployer_frontend_rewrite_ruleset_name
        
    rewrite_rule {
      name                       = local.deployer_frontend_rewrite_rule1_name
      rule_sequence              = 1

      request_header_configuration {
        header_name = "X-Forwarded-Host"
        header_value = "{var_host}"
      }

      request_header_configuration {
        header_name = "X-Forwarded-For"
        header_value = "{var_add_x_forwarded_for_proxy}"
      }
    }
  }

  ####################### backend configs
  
  backend_address_pool {
    name = local.deployer_backend_address_pool_name
  }
  
  backend_http_settings {
    name                  = local.deployer_backend_http_setting_name
    probe_name            = local.deployer_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 5555
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true

    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }
  }

  probe {
    name                  = local.deployer_backend_http_probe_name
    protocol              = "Http"
    path                  = "/invoke/wm.server/ping"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "200"
      ]
    }
  }

  ################################################################
  #### Jenkins specifics
  ################################################################

  http_listener {
    name                           = local.jenkins_frontend_http_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_http_port_name
    protocol                       = "Http"
    host_name                      = var.jenkins_external_host_name
  }

  http_listener {
    name                           = local.jenkins_frontend_https_listener_name
    frontend_ip_configuration_name = local.managementexternal_frontend_ip_configuration_name
    frontend_port_name             = local.managementexternal_frontend_https_port_name
    ssl_certificate_name           = local.managementexternal_frontend_https_ssl_certificate_name
    protocol                       = "Https"
    host_name                      = var.jenkins_external_host_name
  }

  ## http to https redirect
  request_routing_rule {
    name                       = local.jenkins_frontend_http_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.jenkins_frontend_http_listener_name
    redirect_configuration_name = local.jenkins_frontend_http_request_redirect_name
  }
  
  redirect_configuration {
    name = local.jenkins_frontend_http_request_redirect_name
    redirect_type = "Permanent"
    target_listener_name = local.jenkins_frontend_https_listener_name
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = local.jenkins_frontend_https_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.jenkins_frontend_https_listener_name
    backend_address_pool_name  = local.jenkins_backend_address_pool_name
    backend_http_settings_name = local.jenkins_backend_http_setting_name
    rewrite_rule_set_name      = local.jenkins_frontend_rewrite_ruleset_name
  }

  rewrite_rule_set {
    name                       = local.jenkins_frontend_rewrite_ruleset_name
        
    rewrite_rule {
      name                       = local.jenkins_frontend_rewrite_rule1_name
      rule_sequence              = 1

      request_header_configuration {
        header_name = "X-Forwarded-Host"
        header_value = "{var_host}"
      }

      request_header_configuration {
        header_name = "X-Forwarded-For"
        header_value = "{var_add_x_forwarded_for_proxy}"
      }
    }
  }

  ####################### backend configs
  
  backend_address_pool {
    name = local.jenkins_backend_address_pool_name
  }
  
  backend_http_settings {
    name                  = local.jenkins_backend_http_setting_name
    probe_name            = local.jenkins_backend_http_probe_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "lb_cookie"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 5
    pick_host_name_from_backend_address = true

    connection_draining {
      enabled   = true
      drain_timeout_sec = 300
    }
  }

  probe {
    name                  = local.jenkins_backend_http_probe_name
    protocol              = "Http"
    path                  = "/"
    interval              = 5
    timeout               = 2
    unhealthy_threshold   = 2
    pick_host_name_from_backend_http_settings = true
    minimum_servers       = 1

    match {
      #body = ""
      status_code = [
        "200"
      ]
    }
  }
}