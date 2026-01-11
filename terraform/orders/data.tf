data "aws_ssm_parameter" "orders_sg" {
  name  = "/retail_store_aws/orders_sg"
  }

data "aws_ssm_parameter" "private_subnet_id" {
  name  = "/retail_store_aws/private_subnet_id"
}