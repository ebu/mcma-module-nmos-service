#########################
# Provider registration
#########################

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

############################################
# Cloud watch log group for central logging
############################################

resource "aws_cloudwatch_log_group" "main" {
  name = "/mcma/${var.global_prefix}"
}

########################################
# MCMA NMOS Service
########################################

module "mcma_nmos_service" {
  source = "../aws/build/staging"

  prefix           = "${var.global_prefix}-service"

  aws_account_id   = var.aws_account_id
  aws_region       = var.aws_region
  log_group        = aws_cloudwatch_log_group.main
  stage_name       = var.environment_type

  ecs_cluster                 = aws_ecs_cluster.main
  ecs_service_subnets         = [aws_subnet.private.id]
  ecs_service_security_groups = [aws_default_security_group.default.id]
}
