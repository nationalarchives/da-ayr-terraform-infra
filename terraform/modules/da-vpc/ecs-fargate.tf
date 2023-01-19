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

#data "aws_ssm_parameter" "secret_key" {
#  name = "/dev/secret_key"
#}

data "aws_ssm_parameter" "web_db_name_infra" {
  name = "/dev/WEBAPP_DB_NAME_INFRA"
}
data "aws_ssm_parameter" "web_db_name" {
  name = "/dev/WEBAPP_DB_NAME"
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
       "name": "WEBAPP_DB_NAME_INFRA", 
       "value": "${data.aws_ssm_parameter.web_db_name_infra.value}"
      },
      {
       "name": "WEBAPP_DB_NAME", 
       "value": "${data.aws_ssm_parameter.web_db_name.value}"
      },
      {
       "name": "WEBAPP_DB_USER", 
       "value": "webapp_user"
      },
      {
       "name": "WEBAPP_DB_HOST", 
       "value": "dbwebappdev.cnzaefghraly.eu-west-2.rds.amazonaws.com"
      },
      {
       "name": "WEBAPP_DEBUG", 
       "value": "false"
      },
      {
       "name": "WEBAPP_DB_PASSWORD", 
       "value": "v92jhC5BA@0A"
      },
      {
       "name": "SECRET_KEY", 
       "value": "@)l!d#bi8hnwmsg_m02&uzpqq$54bc0)*q8xok_8ni$49qpo1y"
      },
      {
       "name": "KEYCLOACK_BASE_URI", 
       "value": "http://dev-loadbalancer-108847439.eu-west-2.elb.amazonaws.com"
      },
      {
       "name": "KEYCLOACK_REALM_NAME", 
       "value": "ayr"
      },
      {
       "name": "OIDC_RP_CLIENT_ID", 
       "value": "webapp"
      },
      {
       "name": "OIDC_RP_CLIENT_SECRET", 
       "value": "5Qpz3zLnqo42smvTzAkw6gdRk9MRpCuf"
      },
      {
       "name": "KEYCLOACK_DB_NAME", 
       "value": "keycloack"
      },
      {
       "name": "KEYCLOACK_DB_USER", 
       "value": "keycloack"
      },
      {
       "name": "KEYCLOACK_DB_PASSWORD", 
       "value": "k3ycl0ack"
      },
      {
       "name": "KEYCLOAK_ADMIN", 
       "value": "admin"
      },
      {
       "name": "KEYCLOAK_ADMIN_PASSWORD", 
       "value": "Pa55w0rd"
      }
    ],
    "portMappings": [
      {
        "hostPort": 8000,
        "protocol": "tcp",
        "containerPort": 8000
      }
    ],
    "secrets": [],
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
    egress {
    description = ""
    from_port = 5432
    to_port = 5432
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

################################################


resource "aws_cloudwatch_log_group" "ecslogs-keycloak" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-keycloak"
}

resource "aws_security_group" "ecs-sg-keycloak" {
  name = "${var.environment}-ecs-sg-keycloak"
  vpc_id = module.vpc.vpc_id
  description = "ecs security group"
  ingress {
    description = "permit traffic from elb"
    from_port = var.app_port_keycloak
    to_port = var.app_port_keycloak
    protocol = "tcp"
    security_groups = [ aws_security_group.loadbalancer-keycloak.id ]
  }
  egress {
    description = ""
    from_port = 8080
    to_port = 8080
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
  egress {
    description = ""
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
}




resource "aws_ecs_task_definition" "definition-keycloak" {
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
    "image": "${var.image_keycloak}:${var.image_tag_keycloak}",
    "name": "project-container-keycloak",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${aws_cloudwatch_log_group.ecslogs-keycloak.name}",
        "awslogs-stream-prefix": "project-${var.environment}-keycloak"
      }
    },
    "secrets": [],
    "portMappings": [
      {
        "hostPort": 8080,
        "protocol": "tcp",
        "containerPort": 8080
      }
    ],
    "environment": [ 
      {
       "name": "OIDC_RP_CLIENT_SECRET", 
       "value": "yuXvjxsAM4rE1tZ4zzoca81FegW3d0CV"
      },
      {
       "name": "AES_GENERATED_SECRET", 
       "value": "vRwRNWcWca0APWiaPP9IXA"
      },
      {
       "name": "HMAC_GENERATED_SECRET", 
       "value": "VD325oNHYISGJSy0P34L3Q-SX5Jf9aJptXwRHCapr_fN2nOaY9Jqo30ehWtNEQMVGxAOpGc7NHeuFt3rz5409Q"
      },
      {
       "name": "RSA_GENERATED_PRIVATE_KEY",
       "value" : "MIIEowIBAAKCAQEAvt8U2TJ3T0yzSrQ3P9rahhUxpAMSbh8ZxutClty5AS5WWc9hDUj1a2XIqMpj35GKeuHotdyXefKe9lyCOCBluqw/YKK8zMhl8YioTWkmvxwGVJsmqBCd4LHHklQOX8Mn/5ukiNXe1cgjfVNYWft5rNPelXfbauJ2JynqvXatRHdyC7cdLhCSq/kuqJ3tyiK0YXuTBUcNS2KMjASxgbFkKHksDDtMvaLBRjhvv14Jzcpkze8C1hWeCEqpzaq9eJMAK4Nmm3jLKTNyi5osiCAddqtaE84qwnGdGfXaxLDNJsxBfnzVVVCCUoUhtzZcEfcU8RzA5wuCsisVjE5hdY1vdwIDAQABAoIBADEqIyOjJSpO9mvKqeSPyfP5p5S4mdm1tx0O4lMbvae5ONLfYP9cCKNGT35yy3D9+y6V3CxkCryFqz6IK56rcai4z4ZjxL/26pNhgQCXkjxtyo+mezmVNiV3hZGCh0VRbo8fly0L8d8dM08H1d0vsnK7DD1x5xnMBWUnHej5lb3pl5Kg1C+GR6Le8LsUyoJN2V6U7XsPy+FrqrhEi8nEwwgtDwd42dBqig2AMCQTZrlqw76f5EW93DAPE4ZUAPs19GPnJAqCEv0ONRlTj3W5BUhV6+B4qxZsvzBPIbWV+iqtH0J8RuK8YMQquXfuHjrjXowNjieBDsDAZuZgwCXWLmkCgYEA/QYHVWtBOIywi43a1J2ScNtnz7li3ovbTLzB+QLbk9In5ayBcls92/tdGTTt4Xkvd7iRJ576o6mo+uuFunYt2T5SOt4/zWEsbG/+0ewiNY8qD6WkVIFcFlqVlHY4gUzXTm0QpJXc/5I8rJ0al0hNPO/Uet7wOzpq6n4f/N41mSUCgYEAwR3iRHErehKRFhXHsxT94ZTvMvyW5xsCpQGqPGkr2QcUP3c/qhw0iuiVhh/dl0+AmOWSdxYifFmT38jH3R+9hkF4kYRC3xH/zZCQd/6pvXuDG3k9okhOHN1l2uWzJ8OViEwiHnlPJxXxS28RprcrErenoLejUf7DGa3+vJHJqWsCgYByJM8YJMuGdEmMm1D2C6Otj/00A4DrvpIO+zRSXoyqEet3vCulaC3u2GW2Yl9SETZtvvCUvC57uKUHlUp9xKSIVYoJDowf3c+Jl7iQAQOpv80Mw//vM3BUkUbbc72n7v9OXPteFFFfZhxDDpiZWL+nVtY3G+2p+n+TC5TooWHylQKBgQCOSJRTVQZxdIiNOxLdsRO1RuROLqiIMfBq3qUsyVhTGNIkSJoRnaJgziiMn6HGP/9Bp7OYJijWcbFv6iDHnQEoj8hjfo0+iaZtMJwgrPMm9n+MmHF+xcM3pS/MbfznyUS9HUruJPbal2Im7/iTWtVTfxj0Yxjj6s6Ydwf+q3NnbQKBgBqUIlu82ZizTRv7fGYeYdEQ42FXf76u443tZYXKtJrY7QdwDrzog495O9UzsQ0YX+BOnS1z4r3HMXK7r266qozzcesD2aYyKEZFdck+vW/wARC7Cm44a8MTxYp3g7ZJ32t1lBKPi8CLShvaQNfGOxatSjpzSm2CcDvCq/6PuL72"
      },
      {
       "name": "RSA_ENC_GENERATED_PRIVATE_KEY", 
       "value": "MIIEowIBAAKCAQEApU0hD1E9v4BJMg5+q1/O9vCjhujU4HNw2QncSE0FzPpTUvx9dgIHRi2xgfj5RvRxShNTZuUDpSWZNc9qbT3gSqs/p7jafU+36cuu84DkimYG/YpasI3d13jYHqISHRcwAS2NcZo7NWqU4yz3aZ0Ongbi6DfKD4HXvmwsAkF8t+goPsTMkA3HhcHnoXRUToBmNXxI0Vwep4QOw50QfPqapatX3UgxaQ1d2I1q4pKTCgpqnEjxurbObuU0z3Y1ULwr5XU1PlWGLc4fDcYT5Jj4s9jIbcSBEQBLQbVgy2yXAiyYdD43R+Ymgz9ei/V+w0MouEc+jOt7TwE6ic1lj8zSXQIDAQABAoIBAASkuwYEITjs8KFwWMyVn2m+bsmOZtR7SbM/HKoHR99vNMIDB7815WBqTi85gD8nBLuw+UnNqyGLgddKIVI6R7+xOdOLVM/qWl898ocymrjsjsu2hD+rbIzt/xw1L08T5KxTzEJhs8IXYWFUVQrpd4ym4t7lGk7/NcFKpp3VmxxLZKtm7+Hbxyy95AMqURImeZEmNDYlagV1aQPqlMy4rkMncZ6ugC3txHcAZmb5Hxas+Nv1+7ewrLGW2tngBSEFQzM8lu6C+fDIctIVALbSE1GY2MExU39AiSj1TqUPY9OXhTg1Qq4lQf23Ov/dyEOACevqX7jOMSFEnfzi24GgTv0CgYEA2JKuNR2I16vyGg00uwakuv4h+pRdGes0kPDzPaFhrZ90aE5oZ4c90vpxD7FC1g5UDjibQx3cJ+DNOVnWf8WpzYXdyXsLJ1XcZO3cE9m9MVvNCW2CjF/qHPTqWvZrKJ8iCPJTOQHwhGQryYETNwTWyuOsvqzMFdD9JbcTqO7d7T8CgYEAw2TyZdVLpEWR9TOy16bBtHI0brp5x9jlU6TU1MMyKqYHjKwyr0NLqeiynk3iSyAi42vD+b9smtZ3CNimGuiZ6pw/p2c/vUuVcyIGQbNsGSdaipJkn6YYw/5NGCLfGbR6qj5o2nrPGJmNkqpFaIWCAB0mKTgoBt74697731M6LWMCgYEAvh6mB8LRqmMruWr2a2i9m9oUgiFUSbiNAOBE6EmPshdU3WxXgurafyeTsS7veXJCn+lZg2XnKqrR/hK7lpczJVTrCkCV3gYl4ARfOp3e1EG+kRQtkoVww9LNGOVR1Os9uZThMh5dwhsdxVsmPxpkZN/ReeG/lzdLw5wgCiEHeYkCgYAhH63QAZavJHQX40nAMS7JTksBMm+Op4BI67qAzw5kGH1TJaX5/CiJhz8wgveH0MzZTN2OKxtYLF9FiqSuDxx4n0BTOredeYC+Ydg5rxb2NKuurh6MyfWM1EFxhAfaLbRVw/q2fvc4rl9Hq8HUdD2Tk11yw2hVsdr08Xo1Y8CLDQKBgCKHjCmz0HZeRnRmBi/VfH8UmsGDJ24Y7RWDEYJDG4OhK/cT6AE6Wq9dZn+N1DOyugBYNlC7lxn0joIz6/lMgmKvYwIOCwDIOiiwnqahyZ8OcTtup7aASpHXTOGOKIH4Nr4+lPViEHeQ0RFW7B+Ddy6SoNd2GAW42+HzSetDSfCk"
      },
      {
       "name": "KC_DB_URL_HOST", 
       "value": "dbkeycloakdev.cnzaefghraly.eu-west-2.rds.amazonaws.com"
      },
      {
       "name": "KC_DB_URL_DATABASE", 
       "value": "dbkeycloakdev"
      },
      {
       "name": "KC_DB_USERNAME", 
       "value": "keycloack_user"
      },
      {
       "name": "KC_DB_PASSWORD", 
       "value": "@T4eO6v1q3Iy"
      },
      {
       "name": "KEYCLOAK_ADMIN", 
       "value": "admin"
      },
      {
       "name": "KEYCLOAK_ADMIN_PASSWORD", 
       "value": "5ivoX**sK&4b"
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

resource "aws_ecs_service" "service-keycloak" {
  name = "${var.environment}-ecs-service-keycloak"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.definition-keycloak.arn
  desired_count = 1
  launch_type = "FARGATE"
  enable_ecs_managed_tags = true
  enable_execute_command = true
  health_check_grace_period_seconds = 300

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [ aws_security_group.ecs-sg-keycloak.id ]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lbtargets-keycloak.arn
    container_name = "project-container-keycloak"
    container_port = 8080
  }
}