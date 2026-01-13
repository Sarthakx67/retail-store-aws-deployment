resource "aws_instance" "vpn" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id = data.aws_ssm_parameter.public_subnet_id.value
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg.value]
  key_name = "EC2-key"

  tags = {
    Name = "vpn",
    project = "aws-retail-store",
    env = "dev"
  }
}

