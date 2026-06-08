resource "aws_instance" "orders" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  subnet_id = data.aws_ssm_parameter.private_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.orders_sg.value]
  key_name = "EC2-key"
  user_data = filebase64("orders.sh")

  tags = {
    Name = "orders",
    project = "aws-retail-store",
    env = "dev"
  }
}

resource "aws_route53_record" "orders" {
  zone_id = var.zone_id
  name    = "orders"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.orders.private_ip]
}