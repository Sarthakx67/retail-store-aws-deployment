resource "aws_instance" "cart" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  subnet_id = data.aws_ssm_parameter.private_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.cart_sg.value]
  key_name = "EC2-key"
  user_data = filebase64("cart.sh")

  tags = {
    Name = "cart",
    project = "aws-retail-store",
    env = "dev"
  }
}

resource "aws_route53_record" "cart" {
  zone_id = var.zone_id
  name    = "cart"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.cart.private_ip]
}