data "aws_vpc" "da-ayr-dev" {
    id = vpc-0b863d0ff3d5f256e
}


data "aws_availability_zones" "available" {}

resource "aws_security_group" "vpc-endpoint" {
  name        = "da-ayr-private-api"
  description = "Allow HTTPS access to Private API Endpoimt"
  vpc_id      = aws_vpc.da-ayr-dev.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.da-ayr-dev.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.da-ayr-dev.ipv6_cidr_block]
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

data "aws_subnet" "selected" {
  id = subnet-0f277b422ebc26ef8
}


data "aws_vpc_endpoint_service" "da-ayr" {
  service = "execute-api"
}

resource "aws_vpc_endpoint" "da-ayr" {
  vpc_id              = data.aws_vpc.da-ayr-dev.id
  service_name        = data.aws_vpc_endpoint_service.da-ayr.service_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [data.aws_subnet.selected.id]
  security_group_ids = [aws_security_group.vpc-endpoint.id]
}