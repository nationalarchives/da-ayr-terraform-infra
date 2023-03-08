resource "aws_s3_bucket" "da-ayr-data" {
  bucket = "da-ayr-data"
  acl    = "private"

  tags = {
    Name        = "da-ayr-data"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "tre-bag-files" {
  bucket = "tre-bag-files"
  acl    = "private"

  tags = {
    Name        = "tre-bag-files"
    Environment = var.environment
  }
}