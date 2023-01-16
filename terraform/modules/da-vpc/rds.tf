resource "aws_db_subnet_group" "public_subnet_group" {
  name       = "${var.project_name}-${var.environment}-public-subnet-group"
  subnet_ids = module.vpc.public_subnets
}

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "${var.project_name}-${var.environment}-private-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "db_webapp" {
  allocated_storage        = 100 # gigabytes
  backup_retention_period  = 0   # in days
  apply_immediately        = true
  # db_subnet_group_name     = module.vpc.private_subnets
  # db_subnet_group_name     = "${var.rds_public_subnet_group}"
  engine                   = "postgres"
  engine_version           = "14.5"
  identifier               = "${var.project_name}-db-webapp-${var.environment}"
  #subnet_ids              =  aws_db_subnet_group.db_subnet_group_name.subnet_group.id
  db_subnet_group_name     = aws_db_subnet_group.public_subnet_group.id
  # instance_class         = "db.r5.large"
  instance_class           = "db.m6g.large"
  multi_az                 = false
  db_name                  = "${var.project_name}webapp${var.environment}"
  # parameter_group_name     = "mydbparamgroup1" # if you have tuned it
  # password               = "${trimspace(file("${path.module}/secrets/mydb1-password.txt"))}"
  password                 = "TestZaizi1234..##"
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = true # you should always do this
  storage_type             = "gp2"
  username                 = "zaiziuser"
  vpc_security_group_ids   = ["${aws_security_group.db_sg.id}"]
  skip_final_snapshot      = true
}


resource "aws_db_instance" "db_keycloak" {
  allocated_storage        = 100 # gigabytes
  backup_retention_period  = 0   # in days
  apply_immediately        = true
  # db_subnet_group_name     = module.vpc.private_subnets
  # db_subnet_group_name     = "${var.rds_public_subnet_group}"
  engine                   = "postgres"
  engine_version           = "14.5"
  identifier               = "${var.project_name}-db-keycloak-${var.environment}"
  #subnet_ids              =  aws_db_subnet_group.db_subnet_group_name.subnet_group.id
  db_subnet_group_name     = aws_db_subnet_group.public_subnet_group.id
  # instance_class         = "db.r5.large"
  instance_class           = "db.m6g.large"
  multi_az                 = false
  db_name                  = "${var.project_name}dbkeycloak-${var.environment}"
  # parameter_group_name     = "mydbparamgroup1" # if you have tuned it
  #password                 = "${trimspace(file("${path.module}/secrets/mydb1-password.txt"))}"
  password                 = "TestZaizi1234..##"
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = true # you should always do this
  storage_type             = "gp2"
  username                 = "zaiziuser"
  vpc_security_group_ids   = ["${aws_security_group.db_sg.id}"]
  skip_final_snapshot      = true
}

resource "aws_security_group" "db_sg" {
  name = "db_webapp-sg"

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