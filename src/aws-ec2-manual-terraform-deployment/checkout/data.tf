data "aws_ssm_parameter" "checkout_sg" {
  name  = "/retail_store_aws/checkout_sg"
  }

data "aws_ssm_parameter" "private_subnet_id" {
  name  = "/retail_store_aws/private_subnet_id"
}