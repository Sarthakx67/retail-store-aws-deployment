resource "aws_ssm_parameter" "ui_sg" {
  name  = "/retail_store_aws/ui_sg"
  type  = "String"
  value = aws_security_group.ui.id
}

resource "aws_ssm_parameter" "catalog_sg" {
  name  = "/retail_store_aws/catalog_sg"
  type  = "String"
  value = aws_security_group.catalog.id
}

resource "aws_ssm_parameter" "cart_sg" {
  name  = "/retail_store_aws/cart_sg"
  type  = "String"
  value = aws_security_group.cart.id
}

resource "aws_ssm_parameter" "orders_sg" {
  name  = "/retail_store_aws/orders_sg"
  type  = "String"
  value = aws_security_group.orders.id
}

resource "aws_ssm_parameter" "checkout_sg" {
  name  = "/retail_store_aws/checkout_sg"
  type  = "String"
  value = aws_security_group.checkout.id
}

resource "aws_ssm_parameter" "vpn_sg" {
  name  = "/retail_store_aws/vpn_sg"
  type  = "String"
  value = aws_security_group.vpn.id
}
