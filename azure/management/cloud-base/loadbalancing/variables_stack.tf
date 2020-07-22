variable "ssl_cert_mainlb_pfx_path" {
  description = "local path to the SSL key for the LB"
}

variable "ssl_internal_root_ca_cert_path" {
  description = "internal root ca cert for SSL internal comms"
}

variable "ssl_cert_mainlb_pfx_password" {
  description = "SSL cert password"
}

variable "commandcentral_external_host_name" {
  description = "Command Central external host name as understood by the load balancer"
}

variable "mws_external_host_name" {
  description = "MWS external host name as understood by the load balancer"
}

variable "iscore_external_host_name" {
  description = "IS external host name as understood by the load balancer"
}

variable "tnserver_external_host_name" {
  description = "TN external host name as understood by the load balancer"
}

variable "apigateway_external_host_name" {
  description = "API Gateway external host name as understood by the load balancer"
}

variable "deployer_external_host_name" {
  description = "Deployer external host name as understood by the load balancer"
}

variable "jenkins_external_host_name" {
  description = "Jenkins external host name as understood by the load balancer"
}