resource "aws_ecs_cluster" "cluster" {
  name = "ecs-cluster-${var.environment}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_iam_policy_document" "ecs_task_role_assume" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [ "*" ]
  }
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = [ "*" ]
  }
  statement {
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [ "*" ]
  }
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams"
    ]
    resources = [ aws_cloudwatch_log_group.ecslogs.arn  ]
  }
  statement {
    actions = [
      "s3:PutObject"
    ]
    resources = [ "${aws_s3_bucket.ecs_exec.arn}/*" ]
  }
  statement {
    actions = [
      "s3:GetEncryptionConfiguration"
    ]
    resources = [ aws_s3_bucket.ecs_exec.arn ]
  }
  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [ aws_kms_key.ecs_exec.arn ]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [ "*" ]
  }
  # uncomment to allow ecs exec command to be run for debug purposes
  #statement {
  #  actions = [
  #    "ssmmessages:CreateControlChannel",
  #    "ssmmessages:CreateDataChannel",
  #    "ssmmessages:OpenControlChannel",
  #    "ssmmessages:OpenDataChannel"
  #  ]
  #  resources = [ aws_kms_key.ecs_exec.arn ]
  #}
}

#tfsec:ignore:aws-s3-enable-bucket-logging #tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "ecs_exec" {
  bucket_prefix = "${var.environment}-acs-exec"
}


resource "aws_s3_bucket_acl" "ecs_exec" {
  bucket = aws_s3_bucket.ecs_exec.id
  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "ecs_exec" {
  bucket = aws_s3_bucket.ecs_exec.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ecs_exec" {
  bucket = aws_s3_bucket.ecs_exec.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ecs_exec.arn
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_kms_key" "ecs_exec" {
  description = "KMS key for ecs-exec"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

data "aws_iam_policy_document" "ecs_task_execution_parameter_policy" {
  statement {
    actions = [
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
#    resources = [
#     aws_ssm_parameter.config_string.arn,
#      aws_ssm_parameter.master_realm.arn
#    ]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role-${var.environment}"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume.json
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.environment}"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume.json
}

data "aws_iam_policy" "ecs_task_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name = "ecs-task-role-policy-${var.environment}"
  path = "/"
  description = "AWS IAM Policy for ecs task"
  policy = data.aws_iam_policy_document.ecs_task_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
}

resource "aws_iam_policy" "ecs-task-execution-parameter-policy" {
  name = "ecs-task-execution-parameters-policy-${var.environment}"
  path = "/"
  description = "AWS IAM Policy to allow ECS and FARGATE to fetch parameters and secrets"
  policy = data.aws_iam_policy_document.ecs_task_execution_parameter_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-parameters-policy" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs-task-execution-parameter-policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

resource "random_string" "session" {
  length = 40
  lower = true
  min_lower = 4
  upper = true
  min_upper = 4
  numeric = true
  min_numeric = 4
  special = true
  min_special = 4
  override_special = "-#,"
}

# SAMPLE DATA PASSED TO NODE
#resource "aws_ssm_parameter" "config_string" {
#  name = "/${var.environment}/config_string"
#  type = "SecureString"
#  value = "${random_string.session.result}"
#}

#resource "aws_ssm_parameter" "master_realm" {
#  name = "/${var.environment}/master_realm"
#  type = "SecureString"
#  value = "${random_string.session.result}"
#}${aws_ssm_parameter.master_realm.arn}

data "aws_ssm_parameter" "secret_key" {
  name = "/dev/secret_key"
}
data "aws_ssm_parameter" "secret_key_sig" {
  name = "/dev/secret_key_sig"
}





#tfsec:ignore:aws-cloudwatch-log-group-customer-key:exp:2022-08-08 FIXME
resource "aws_cloudwatch_log_group" "ecslogs" {
  name_prefix = "${var.project_name}-${var.environment}-ecs"
}

resource "aws_ecs_task_definition" "definition" {
  family = "task_definition_name"
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode = "awsvpc"
  cpu = "512"
  memory = "2048"
  requires_compatibilities = [ "FARGATE" ]

  container_definitions = <<DEFINITION
[
  {
    "image": "${var.image}:${var.image_tag}",
    "name": "project-container",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.ecslogs.name}",
        "awslogs-stream-prefix": "project-${var.environment}"
      }
    },
    "environment": [
      {
       "name": "WEBAPP_DB_NAME", 
       "value": "django"
      },
      {
       "name": "WEBAPP_DB_USER", 
       "value": "django"
      },
      {
       "name": "WEBAPP_DB_HOST", 
       "value": "test"
      },
      {
       "name": "WEBAPP_DEBUG", 
       "value": "false"
      },
      {
       "name": "WEBAPP_DB_PASSWORD", 
       "value": "dj4ng0"
      }
    ],
    "portMappings": [
      {
        "hostPort": 8000,
        "protocol": "tcp",
        "containerPort": 8000
      }
    ],
    "secrets": [
      {
        "name": "config",
        "valueFrom": "django"
      }
    ],
    "runtimePlatform": {	
      "operatingSystemFamily": "LINUX"
    },
    "linuxParameters": {
      "initProcessEnabled": true
    }
  }
]
DEFINITION
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group" "ecs-sg" {
  name = "${var.environment}-ecs-sg"
  vpc_id = module.vpc.vpc_id
  description = "ecs security group"
  ingress {
    description = "permit traffic from elb"
    from_port = var.app_port
    to_port = var.app_port
    protocol = "tcp"
    security_groups = [ aws_security_group.loadbalancer.id ]
  }
  egress {
    description = ""
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  egress {
    description = ""
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  egress {
    description = ""
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
  egress {
    description = ""
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
}

resource "aws_ecs_service" "service" {
  name = "${var.environment}-ecs-service"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.definition.arn
  desired_count = 1
  launch_type = "FARGATE"
  enable_ecs_managed_tags = true
  enable_execute_command = true
  health_check_grace_period_seconds = 300

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [ aws_security_group.ecs-sg.id ]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lbtargets.arn
    container_name = "project-container"
    container_port = 8000
  }
}
