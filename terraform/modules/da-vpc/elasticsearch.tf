# variable "vpc" {}

# variable "domain" {
#   default = "tf-test"
# }

# data "aws_vpc" "selected" {
#   tags = {
#     Name = var.vpc
#   }
# }

# data "aws_subnet_ids" "selected" {
#   vpc_id = data.aws_vpc.selected.id

#   tags = {
#     Tier = "private"
#   }
# }

# data "aws_region" "current" {}

# data "aws_caller_identity" "current" {}

resource "aws_security_group" "es" {
  #name        = "${var.vpc}-elasticsearch-${var.domain}"
  name        = "${var.project_name}-elasticsearch-${var.environment}-sg"
  description = "Managed by Terraform"
  #vpc_id      = data.aws_vpc.selected.id
  vpc_id      =   module.vpc.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      #data.aws_vpc.selected.cidr_block,
      var.vpc_cidr
    ]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
#   domain_name           = var.domain

    domain_name ="${var.project_name}-elasticsearch-${var.environment}"

    elasticsearch_version = "6.3"

    cluster_config {
        instance_type          = "m4.large.elasticsearch"
        zone_awareness_enabled = true
    }

   vpc_options {
    # subnet_ids = [
    #   data.aws_subnet_ids.selected.ids[0],
    #   data.aws_subnet_ids.selected.ids[1],
    # ]
        subnet_ids =   aws_db_subnet_group.private_subnet_group

        security_group_ids = [aws_security_group.es.id]
    }

    advanced_options = {
        "rest.action.multi.allow_explicit_index" = "true"
     }

    access_policies = <<CONFIG
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:eu-west-2:281072317055:domain/da-ayr-opensearch-dev/*"
        }
    ]
    }

    CONFIG

# "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"

  tags = {
    # Domain = "TestDomain"
    Domain = "${var.project_name}-elasticsearch-${var.environment}"
  }

  depends_on = [aws_iam_service_linked_role.es]
}