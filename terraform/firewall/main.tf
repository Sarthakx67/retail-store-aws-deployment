resource "aws_security_group" "ui" {
  name        = "ui"
  description = "Allow public inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "ui"
  }
}

resource "aws_security_group" "catalog" {
  name        = "catalog"
  description = "Allow catalog inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "catalog"
  }
}

resource "aws_security_group" "cart" {
  name        = "cart"
  description = "Allow cart inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "cart"
  }
}

resource "aws_security_group" "orders" {
  name        = "orders"
  description = "Allow orders inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "orders"
  }
}

resource "aws_security_group" "checkout" {
  name        = "checkout"
  description = "Allow checkout inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "checkout"
  }
}

resource "aws_security_group" "vpn" {
  name        = "vpn"
  description = "Allow vpn inbound traffic and all outbound traffic"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = "aws-retail-store",
    env = "dev",
    Name = "vpn"
  }
}


####### direct ec2 access for testing purpose ######################################################

resource "aws_vpc_security_group_ingress_rule" "ui_ssh" {
  security_group_id = aws_security_group.ui.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "cataloge_ssh" {
  security_group_id = aws_security_group.catalog.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "cart_ssh" {
  security_group_id = aws_security_group.cart.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "orders_ssh" {
  security_group_id = aws_security_group.orders.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "checkout_ssh" {
  security_group_id = aws_security_group.checkout.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "ui_service_port" {
  security_group_id = aws_security_group.ui.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ui_service_port # 8080 for ui
  ip_protocol       = "tcp"
  to_port           = var.ui_service_port
}

resource "aws_vpc_security_group_ingress_rule" "vpn_ssh" {
  security_group_id = aws_security_group.vpn.id
  cidr_ipv4         = var.public_cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

############################################################################################################

resource "aws_security_group_rule" "ui_vpn" {
  # providing  sg 
  security_group_id = aws_security_group.ui.id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = aws_security_group.vpn.id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "catalog_vpn" {
  # providing  sg 
  security_group_id = aws_security_group.catalog.id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = aws_security_group.vpn.id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "cart_vpn" {
  # providing  sg 
  security_group_id = aws_security_group.cart.id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = aws_security_group.vpn.id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "orders_vpn" {
  # providing  sg 
  security_group_id = aws_security_group.orders.id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = aws_security_group.vpn.id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}

resource "aws_security_group_rule" "checkout_vpn" {
  # providing  sg 
  security_group_id = aws_security_group.checkout.id
  type = "ingress"
  # source is the main sg to connect  sg to access connection from
  source_security_group_id = aws_security_group.vpn.id
  from_port   = 22
  protocol = "tcp"
  to_port     = 22
}


resource "aws_security_group_rule" "catalog_from_ui" {
  # Allow traffic TO <security_group_id> FROM <source_security_group_id>
  type                     = "ingress"
  security_group_id        = aws_security_group.catalog.id
  source_security_group_id = aws_security_group.ui.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "cart_from_ui" {
  # Allow traffic TO <security_group_id> FROM <source_security_group_id>
  type                     = "ingress"
  security_group_id        = aws_security_group.cart.id
  source_security_group_id = aws_security_group.ui.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "orders_from_ui" {
  # Allow traffic TO <security_group_id> FROM <source_security_group_id>
  type                     = "ingress"
  security_group_id        = aws_security_group.orders.id
  source_security_group_id = aws_security_group.ui.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "checkout_from_ui" {
  # Allow traffic TO <security_group_id> FROM <source_security_group_id>
  type                     = "ingress"
  security_group_id        = aws_security_group.checkout.id
  source_security_group_id = aws_security_group.ui.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
}