resource "aws_ssm_parameter" "vpc_id" {
  name  = "/retail_store_aws/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "vpc_cidr_block" {
  name  = "/retail_store_aws/vpc_cidr_block"
  type  = "String"
  value = var.vpc_cidr_block
}

resource "aws_ssm_parameter" "public_subnet_id" {
  name  = "/retail_store_aws/public_subnet_id"
  type  = "String"
  value = aws_subnet.public.id
}

resource "aws_ssm_parameter" "public_cidr_block" {
  name  = "/retail_store_aws/public_cidr_block"
  type  = "String"
  value = var.public_subnet_cidr_block
}

resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "/retail_store_aws/private_subnet_id"
  type  = "String"
  value = aws_subnet.private.id
}

resource "aws_ssm_parameter" "private_cidr_block" {
  name  = "/retail_store_aws/private_cidr_block"
  type  = "String"
  value = var.private_subnet_cidr_block
}

resource "aws_ssm_parameter" "igw_id" {
  name  = "/retail_store_aws/igw_id"
  type  = "String"
  value = aws_internet_gateway.igw.id
}