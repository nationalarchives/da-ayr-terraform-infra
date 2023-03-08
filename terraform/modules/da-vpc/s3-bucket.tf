resource "aws_s3_bucket" "da_ayr_data" {
  bucket = "da-ayr-data"
  acl    = "private"

  tags = {
    Name        = "da-ayr-data"
    Environment = var.environment
  }
}
resource "aws_s3_bucket_public_access_block" "da-ayr-data" {
  bucket = aws_s3_bucket.da_ayr_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "tre_bag_files" {
  bucket = "tre-bag-files"
  acl    = "private"

  tags = {
    Name        = "tre-bag-files"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "tre_bag_files" {
  bucket = aws_s3_bucket.tre_bag_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
