resource "aws_instance" "checkout" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  # subnet_id = data.aws_ssm_parameter.private_subnet_id.value
  # vpc_security_group_ids = [data.aws_ssm_parameter.checkout_sg.value]
  key_name = "EC2-key"
  user_data = filebase64("checkout.sh")

  tags = {
    Name = "checkout",
    project = "aws-retail-store",
    env = "dev"
  }
}

# resource "aws_route53_record" "checkout" {
#   zone_id = var.zone_id
#   name    = "checkout"
#   type    = "A"
#   ttl     = "1"
#   records = [aws_instance.checkout.private_ip]
# }