resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-logs-${var.environment}"
  tags = {
    Name        = "${var.project_name}-logs-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "logs-policy" {
  bucket = "${var.project_name}-logs-${var.environment}"
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "AWSConsole-AccessLogs-Policy-1669057496110",
    "Statement": [
        {
            "Sid": "AWSConsoleStmt-1669057496110",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::652711504416:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.project_name}-logs-${var.environment}/logs/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.project_name}-logs-${var.environment}/logs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.project_name}-logs-${var.environment}"
        }
    ]
  }
  POLICY
}

resource "aws_s3_bucket_versioning" "versioning_logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}


resource "aws_s3_object" "logs-artefacts" {
  bucket = aws_s3_bucket.logs.bucket
  acl    = aws_s3_bucket_acl.logs.acl
  key    = "logs/artefacts/"
}

resource "aws_s3_object" "logs-tfstate" {
  bucket = aws_s3_bucket.logs.bucket
  acl    = aws_s3_bucket_acl.logs.acl
  key    = "logs/tfstate/"
}

resource "aws_s3_object" "logs-load-balancer" {
  bucket = aws_s3_bucket.logs.bucket
  acl    = aws_s3_bucket_acl.logs.acl
  key    = "logs/load-balancer/"
}
