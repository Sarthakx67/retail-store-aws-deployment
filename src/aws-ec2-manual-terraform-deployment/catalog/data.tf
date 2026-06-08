data "aws_ssm_parameter" "catalog_sg" {
  name  = "/retail_store_aws/catalog_sg"
  }

data "aws_ssm_parameter" "private_subnet_id" {
  name  = "/retail_store_aws/private_subnet_id"
}