resource "aws_iam_role" "nmos_registry" {
  name               = format("%.64s", "${var.prefix}-${var.aws_region}-nmos-registry")
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
        Effect : "Allow"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "nmos_registry" {
  name   = format("%.128s", "${var.prefix}-${var.aws_region}-nmos-registry")
  path   = var.iam_policy_path
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid : "AllowWritingToLogs"
        Effect : "Allow",
        Action : "logs:*",
        Resource : "*"
      },
      {
        Sid : "AllowRunningInVPC",
        Effect : "Allow",
        Action : [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface"
        ]
        Resource : "*"
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "nmos_registry" {
  role       = aws_iam_role.nmos_registry.id
  policy_arn = aws_iam_policy.nmos_registry.arn
}

resource "aws_ecs_task_definition" "nmos_registry" {
  family = "${var.prefix}-nmos-registry"

  container_definitions = jsonencode([
    {
      name : "nmos-registry",
      cpu : 0,
      environment : [
        {
          name : "RUN_NODE",
          value : "FALSE"
        },
      ],
      essential : true,
      image : "rhastie/nmos-cpp:latest",
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          "awslogs-group" : var.log_group.name,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : "ecs"
        }
      },
      portMappings : [
        {
          containerPort : 1883,
          hostPort : 1883,
          protocol : "tcp"
        },
        {
          containerPort : 8010,
          hostPort : 8010,
          protocol : "tcp"
        },
        {
          containerPort : 8011,
          hostPort : 8011,
          protocol : "tcp"
        }
      ],
      volumesFrom : []
    }
  ])

  cpu          = 256
  memory       = 512
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.nmos_registry.arn

  requires_compatibilities = ["FARGATE"]

  tags = var.tags
}

resource "aws_ecs_service" "nmos_registry" {
  name             = "${var.prefix}-nmos-registry"
  cluster          = var.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.nmos_registry.arn
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = [var.ecs_service_subnet]
    security_groups  = [var.ecs_service_security_group]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nmos_registry_1883.arn
    container_name   = "nmos-registry"
    container_port   = 1883
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nmos_registry_8010.arn
    container_name   = "nmos-registry"
    container_port   = 8010
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nmos_registry_8011.arn
    container_name   = "nmos-registry"
    container_port   = 8011
  }

  desired_count = 1

  tags = var.tags
}

resource "aws_lb" "nmos_registry" {
  name               = format("%.32s", var.prefix)
  internal           = true
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id            = var.dns_subnet.id
    private_ipv4_address = var.rds_ip_address
  }

  tags = var.tags
}

resource "aws_lb_target_group" "nmos_registry_1883" {
  name        = "nmos-registry-tcp-1883"
  port        = 1883
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc.id

  tags = var.tags
}

resource "aws_lb_listener" "nmos_registry_1883" {
  load_balancer_arn = aws_lb.nmos_registry.arn
  port              = 1883
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nmos_registry_1883.arn
  }
}

resource "aws_lb_target_group" "nmos_registry_8010" {
  name        = "nmos-registry-tcp-8010"
  port        = 8010
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc.id

  tags = var.tags
}

resource "aws_lb_listener" "nmos_registry_8010" {
  load_balancer_arn = aws_lb.nmos_registry.arn
  port              = 8010
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nmos_registry_8010.arn
  }
}

resource "aws_lb_target_group" "nmos_registry_8011" {
  name        = "nmos-registry-tcp-8011"
  port        = 8011
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc.id

  tags = var.tags
}

resource "aws_lb_listener" "nmos_registry_8011" {
  load_balancer_arn = aws_lb.nmos_registry.arn
  port              = 8011
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nmos_registry_8011.arn
  }
}
