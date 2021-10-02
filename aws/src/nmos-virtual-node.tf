resource "aws_iam_role" "nmos_virtual_node" {
  name               = format("%.64s", "${var.prefix}-${var.aws_region}-nmos-virtual-node")
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

resource "aws_iam_policy" "nmos_virtual_node" {
  name   = format("%.128s", "${var.prefix}-${var.aws_region}-nmos-virtual-node")
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

resource "aws_iam_role_policy_attachment" "nmos_virtual_node" {
  role       = aws_iam_role.nmos_virtual_node.id
  policy_arn = aws_iam_policy.nmos_virtual_node.arn
}

resource "aws_ecs_task_definition" "nmos_virtual_node" {
  family = var.prefix

  container_definitions = jsonencode([
    {
      name : "nmos-virtual-node",
      cpu : 0,
      environment : [
        {
          name : "RUN_NODE",
          value : "TRUE"
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
          containerPort : 11000,
          hostPort : 11000,
          protocol : "tcp"
        },
        {
          containerPort : 11001,
          hostPort : 11001,
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
  task_role_arn      = aws_iam_role.nmos_virtual_node.arn

  requires_compatibilities = ["FARGATE"]

  tags = var.tags
}

resource "aws_ecs_service" "nmos_virtual_node" {
  name             = "${var.prefix}-nmos-virtual-node"
  cluster          = var.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.nmos_virtual_node.arn
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets         = var.ecs_service_subnets
    security_groups = var.ecs_service_security_groups
  }

  desired_count = 1

  tags = var.tags
}
