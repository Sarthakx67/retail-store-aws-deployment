data "aws_ssm_parameter" "ui_sg" {
  name  = "/retail_store_aws/ui_sg"
  }

data "aws_ssm_parameter" "public_subnet_id" {
  name  = "/retail_store_aws/public_subnet_id"
}