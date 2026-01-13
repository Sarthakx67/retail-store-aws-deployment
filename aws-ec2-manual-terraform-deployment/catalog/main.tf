resource "aws_instance" "catalog" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  subnet_id = data.aws_ssm_parameter.private_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.catalog_sg.value]
  key_name = "EC2-key"
  user_data = filebase64("catalog.sh")

  tags = {
    Name = "catalog",
    project = "aws-retail-store",
    env = "dev"
  }
}

resource "aws_route53_record" "catalog" {
  zone_id = var.zone_id
  name    = "catalog"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.catalog.private_ip]
}