resource "random_string" "cloudfront_identifier_keycloak" {
  length = 40
  lower = true
  min_lower = 4
  upper = true
  min_upper = 4
  numeric = true
  min_numeric = 4
  special = true
  min_special = 4
  override_special = "-#!,"
}

#tfsec:ignore:aws-s3-enable-bucket-logging #tfsec:ignore:aws-s3-enable-versioning
/*
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket_prefix = "${var.project_name}-${var.environment}-cloudfront-logs"
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl = "private"
}


resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudfront_logs.arn
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_kms_key" "cloudfront_logs" {
  description = "KMS key for cloudfront logs"
  deletion_window_in_days = 10
  enable_key_rotation = true
}
*/



resource "aws_cloudfront_distribution" "cf_distribution_keycloak" {
  enabled = true
  is_ipv6_enabled = true
  comment = "Cloudfront keycloak ${var.environment}"
  price_class = "PriceClass_100"
  provider = aws.us-east-1
  #provider = aws.eu-west-2

  origin {
    domain_name =aws_lb.loadbalancer-keycloak.dns_name
    #domain_name = aws_lb.loadbalancer.dns_name
    origin_id = "ecs-alb"
    custom_origin_config {
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [ "TLSv1.2" ]
      https_port = "443"
      http_port = "80"
    }
    custom_header {
      name = "x-cloudfront-identifier"
      value = random_string.cloudfront_identifier_keycloak.result
    }
  }
  
  /*
  logging_config {
    include_cookies = false
    bucket = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix = var.environment
  }
  */
  

  aliases = [ var.fqdn_keycloak ]
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods = [ "HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = "ecs-alb"

    forwarded_values {
      query_string = true
      headers = [ "*" ]
      cookies {
        forward = "all"
      }
    }

    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
    compress = true
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.cloudfront_keycloak.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # web_acl_id = aws_wafv2_web_acl.cloudfront.arn
}

resource "aws_route53_record" "cloudfront_keycloak" {
  zone_id = data.aws_route53_zone.dnszone_keycloak.zone_id
  name = var.fqdn_keycloak
  type = "A"

  alias {
    name = aws_cloudfront_distribution.cf_distribution_keyclok.domain_name
    #name = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id = aws_cloudfront_distribution.cf_distribution_keycloak.hosted_zone_id
    evaluate_target_health = true
  }
}