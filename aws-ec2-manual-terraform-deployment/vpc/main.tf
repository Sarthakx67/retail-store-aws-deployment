resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    project = "aws-retail-store"
    env     = "dev"
    Name    = "aws-retail-store-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block
  # Most Imp Thing
  map_public_ip_on_launch = true


  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "aws-retail-store-public-subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block
  # turn it off after testing
  map_public_ip_on_launch = true

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "aws-retail-store-private-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "aws-retail-store-igw"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    project = "aws-retail-store",
    env = "dev"
    Name = "aws-retail-store-public-rt"
  }
}
resource "aws_route_table" "private" { # connect it with nat gateway in prod currently with igw for cost optimisation
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    project = "aws-retail-store",
    env = "dev"
    Name = "aws-retail-store-private-rt"
  } 
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}