resource "aws_vpc" "inbound" {
    cidr_block = "10.0.0.0/16"
    tags = var.vpc_tags
}