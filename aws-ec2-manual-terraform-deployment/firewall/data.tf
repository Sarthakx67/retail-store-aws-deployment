data "aws_ssm_parameter" "vpc_id" {
  name  = "/retail_store_aws/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  name  = "/retail_store_aws/public_subnet_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
  name  = "/retail_store_aws/private_subnet_id"
}

data "aws_ssm_parameter" "igw_id" {
  name  = "/retail_store_aws/igw_id"
}

data "aws_ssm_parameter" "vpc_cidr_block" {
  name  = "/retail_store_aws/vpc_cidr_block"
}

data "aws_ssm_parameter" "public_cidr_block" {
  name  = "/retail_store_aws/public_cidr_block"
}

data "aws_ssm_parameter" "private_cidr_block" {
  name  = "/retail_store_aws/private_cidr_block"
}
