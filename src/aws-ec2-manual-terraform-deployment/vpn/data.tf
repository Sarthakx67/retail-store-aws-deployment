data "aws_ssm_parameter" "vpn_sg" {
  name  = "/retail_store_aws/vpn_sg"
  }

data "aws_ssm_parameter" "public_subnet_id" {
  name  = "/retail_store_aws/public_subnet_id"
}