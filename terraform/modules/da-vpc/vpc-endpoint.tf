resource "aws_security_group" "vpc-endpoint" {
  name        = "da-ayr-private-api"
  description = "Allow HTTPS access to Private API Endpoimt"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

data "aws_vpc_endpoint_service" "da-ayr" {
  service = "execute-api"
}

resource "aws_vpc_endpoint" "da-ayr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = data.aws_vpc_endpoint_service.da-ayr.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [module.vpc.private_subnets[0]]
  security_group_ids = [aws_security_group.vpc-endpoint.id]
}