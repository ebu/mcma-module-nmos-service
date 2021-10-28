#########################
# Environment Variables
#########################

variable "prefix" {
  type        = string
  description = "Prefix for all managed resources in this module"
}

variable "stage_name" {
  type        = string
  description = "Stage name to be used for the API Gateway deployment"
}

variable "log_group" {
  type        = object({
    id   = string
    arn  = string
    name = string
  })
  description = "Log group used by MCMA Event tracking"
}

variable "dead_letter_config_target" {
  type        = string
  description = "Configuring dead letter target for worker lambda"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to created resources"
  default     = {}
}

#########################
# AWS Variables
#########################

variable "aws_account_id" {
  type        = string
  description = "Account ID to which this module is deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS Region to which this module is deployed"
}

variable "iam_role_path" {
  type        = string
  description = "Path for creation of access role"
  default     = "/"
}

variable "iam_policy_path" {
  type        = string
  description = "Path for creation of access policy"
  default     = "/"
}

#########################
# Dependencies
#########################
#
#variable "service_registry" {
#  type = object({
#    auth_type    = string,
#    services_url = string,
#  })
#}

#########################
# Configuration
#########################

variable "api_gateway_logging_enabled" {
  type        = bool
  description = "Enable API Gateway logging"
  default     = false
}

variable "api_gateway_metrics_enabled" {
  type        = bool
  description = "Enable API Gateway metrics"
  default     = false
}

variable "xray_tracing_enabled" {
  type        = bool
  description = "Enable X-Ray tracing"
  default     = false
}

#####################################
# VPC configuration
#####################################
variable "vpc" {
  type        = object({
    id = string
  })
  description = "VPC in which everything will run"
}

variable "ec2_key_pair" {
  type        = object({
    key_name = string
  })
  description = "Key pair to connect with EC2 instances"
}

variable "dns_subnet" {
  type        = object({
    id = string
  })
  description = "Subnet for dns service"
}

variable "dns_ip_address" {
  type        = string
  description = "IP Address on which dns service will run"
}

variable "dns_domain_name" {
  type        = string
  description = "Domain name used by DNS service"
}

#####################################
# ECS service configuration
#####################################

variable "ecs_cluster" {
  type        = object({
    id   = string
    name = string
  })
  description = "ECS cluster in which NMOS containers will be placed"
}

variable "ecs_service_subnet" {
  type        = string
  description = "Subnet in which NMOS containers will be placed"
}

variable "ecs_service_security_group" {
  type        = string
  description = "Security groups in which NMOS containers will be placed"
}

variable "rds_ip_address" {
  type        = string
  description = "IP Address on which the load balancer for NMOS registry service will run"
}
