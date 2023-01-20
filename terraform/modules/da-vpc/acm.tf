/*
resource "aws_acm_certificate" "certificate" {
  domain_name = var.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cloudfront" {
  # provider = aws.us-east-1
  provider = aws.eu-west-2
  domain_name = var.fqdn
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "dnszone" {
  name = "ayr.labs.zaizicloud.net"
  #name = "${var.fqdn}"
  #name = join(".", slice(split(".", var.fqdn), 1, length(split(".", var.fqdn))))
  private_zone = false
}

resource "aws_route53_record" "cert-validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options: dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [ each.value.record ]
  ttl = 60
  type = each.value.type
  zone_id = data.aws_route53_zone.dnszone.zone_id
}

resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [ for record in aws_route53_record.cert-validation: record.fqdn ]
}
*/
