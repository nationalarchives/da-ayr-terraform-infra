provider "aws" {
  region = "eu-west-2"
  # profile                 = "nhsbsa"
  # assume_role {
  #   role_arn = "arn:aws:iam::626513967161:role/Zaizi-Cloud-Engineer"
  # }
  assume_role {
    role_arn = var.assume_role.nonprod
  }
}
