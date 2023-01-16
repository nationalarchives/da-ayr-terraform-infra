resource "aws_db_instance" "mydb1" {
  allocated_storage        = 256 # gigabytes
  backup_retention_period  = 7   # in days
  # db_subnet_group_name     = module.vpc.private_subnets
  # db_subnet_group_name     = "${var.rds_public_subnet_group}"
  engine                   = "postgres"
  engine_version           = "13.7-R1"
  identifier               = "mydb1"
  instance_class           = "db.m5d.large"
  multi_az                 = false
  db_name                  = "mydb1"
  parameter_group_name     = "mydbparamgroup1" # if you have tuned it
  # password               = "${trimspace(file("${path.module}/secrets/mydb1-password.txt"))}"
  password                 = "Zaizi-Org##.."
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = true # you should always do this
  storage_type             = "gp2"
  username                 = "mydb1"
  vpc_security_group_ids   = ["${aws_security_group.mydb1.id}"]
}

resource "aws_security_group" "mydb1" {
  name = "mydb1"

  description = "RDS postgres servers (terraform-managed)"
  #vpc_id = "${var.rds_vpc_id}"
  vpc_id =  module.vpc.vpc_id

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#variable "rds_vpc_id" {
#  default = "vpc-XXXXXXXX"
#  description = "Our default RDS virtual private cloud (rds_vpc)."
#}

#variable "rds_public_subnets" {
#  default = "subnet-YYYYYYYY,subnet-YYYYYYYY,subnet-YYYYYYYY,subnet-YYYYYYYY"
#  description = "The public subnets of our RDS VPC rds-vpc."
#}

#variable "rds_public_subnet_group" {
#  default = "default-vpc-XXXXXXXX"
#  description = "Apparently the group name, according to the RDS launch wizard."
#}