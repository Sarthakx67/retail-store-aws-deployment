data "aws_ssm_parameter" "cart_sg" {
  name  = "/retail_store_aws/cart_sg"
  }

data "aws_ssm_parameter" "private_subnet_id" {
  name  = "/retail_store_aws/private_subnet_id"
}