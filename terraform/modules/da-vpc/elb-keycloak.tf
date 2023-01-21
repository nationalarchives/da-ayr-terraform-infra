#tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "loadbalancer-keycloak" {
  name = "${var.environment}-keycloak-loadbalancer"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.loadbalancer-keycloak.id ]
  subnets = module.vpc.public_subnets
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  access_logs {
    bucket  = aws_s3_bucket.logs.id
    #bucket  = "nhsbsa-vdps-logs-infra-${var.environment}"
    prefix  = "logs/load-balancer"
    enabled = true
  }
}

resource "aws_lb_target_group" "lbtargets-keycloak" {
  name = "tf-lb-target-keycloak-${var.environment}"
  port = var.app_port_keycloak
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    matcher = "200-399"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 10
  }
}

resource "aws_lb_target_group" "lbtargets-keycloak-1" {
  name = "tf-lb-target-keycloak-1-${var.environment}"
  port = var.app_port_keycloak
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    matcher = "200-399"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 10
  }
}

resource "aws_lb_listener" "httpslistener-keycloak" {
  load_balancer_arn = aws_lb.loadbalancer-keycloak.arn
  port = "80"
  protocol = "HTTP"
  #certificate_arn = aws_acm_certificate_validation.cert-validation.certificate_arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lbtargets-keycloak.arn
  }
}

resource "aws_lb_listener" "httpslistener-keycloak-1" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = "443"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate_validation.cert-validation.certificate_arn
  
  default_action {
  type = "forward"
    target_group_arn = aws_lb_target_group.lbtargets-keycloak-1.arn
  }
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr #tfsec:ignore:aws-vpc-no-public-ingress-sgr
resource "aws_security_group" "loadbalancer-keycloak" {
  name = "${var.environment}-keycloak-lb-sg"
  vpc_id = module.vpc.vpc_id
  description = "loadbalancer security group"

  ingress {
    description = "permit HTTP ingres"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  ingress {
    description = "permit HTTPS ingres"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
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
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
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
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
}