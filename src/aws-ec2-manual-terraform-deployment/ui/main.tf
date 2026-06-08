resource "aws_instance" "ui" {
  ami           = var.ami_id
  instance_type = "t2.medium"
  subnet_id = data.aws_ssm_parameter.public_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.ui_sg.value]
  key_name = "EC2-key"
  user_data = file("ui.sh")

  tags = {
    Name = "ui",
    project = "aws-retail-store",
    env = "dev"
  }
}

resource "aws_route53_record" "ui" {
  zone_id = var.zone_id
  name    = "ui"
  type    = "A"
  ttl     = "1"
  records = [aws_instance.ui.public_ip]
}