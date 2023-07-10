resource "aws_vpc" "nonprod" {
    cidr_block = var.vpc_cidr_block
    tags = var.vpc_tags
}

resource "aws_internet_gateway" "public" {
     vpc_id = aws_vpc.nonprod.id
     tags = var.igw_tags

}

#PUBLIC WORLD

resource "aws_subnet" "public" {
     count = length(local.selected_azs)
     vpc_id = aws_vpc.nonprod.id
     cidr_block = var.subnet_cidr_pub[count.index]
     availability_zone = local.selected_azs[count.index]
     tags = merge(
          var.pub_subnet_tags,{
               Name = "${var.vpc_name}_Pub_${local.tails[count.index]}"
          }
     )

}

resource "aws_route_table" "rt_pub_ig"{
     vpc_id = aws_vpc.nonprod.id
     route  {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.public.id
     }
     tags = merge(var.route_tags,{
               Name = "${var.vpc_name}_Pub"
          })
}

resource "aws_route_table_association" "rt_pub_sub" {
     count = length(var.subnet_cidr_pub) #this will fetch the count of subnets
     subnet_id = element(aws_subnet.public[*].id, count.index)
     route_table_id = aws_route_table.rt_pub_ig.id
}

#PRIVATE WORLD

resource "aws_subnet" "private" {
     count = length(local.selected_azs)
     vpc_id = aws_vpc.nonprod.id
     cidr_block = var.subnet_cidr_priv[count.index]
     availability_zone = local.selected_azs[count.index]
     tags = merge(
          var.priv_subnet_tags,{
               Name = "${var.vpc_name}_priv_${local.tails[count.index]}"
          }
     )

}

resource "aws_route_table" "rt_priv_ig"{
     vpc_id = aws_vpc.nonprod.id
     
     tags = merge(var.route_tags,{
               Name = "${var.vpc_name}_priv"
          })
}

resource "aws_route_table_association" "rt_ppriv_sub" {
     count = length(var.subnet_cidr_priv) #this will fetch the count of subnets
     subnet_id = element(aws_subnet.private[*].id, count.index)
     route_table_id = aws_route_table.rt_priv_ig.id
}

resource "aws_eip" "nat" {
     domain = "vpc"
     tags = merge(var.eip_tags,{
               Name = "${var.vpc_name}_Pub"
          })
}

resource "aws_nat_gateway" "nat_eip" {
     allocation_id = "${aws_eip.nat.id}"
     subnet_id = "${aws_subnet.public[0].id}"
     tags = merge(var.nat_tags,{
               Name = "${var.vpc_name}_Pub"
          })
}

#Security WORLD

resource "aws_security_group" "inbound_noprod" {
     name = var.security_group_name
     description = var.security_group_description
     vpc_id = var.VPC_ID

     ingress {
          for_each = var.ingress_nonprod
          from_port = each.value.from_port
          to_port = each.value.to_port
          protocol = each.value.protocol
          cidr_blocks = each.value.cidr_blocks
          description = each.value.description
          

     }

      egress {
          for_each = var.ingress_nonprod
          from_port = each.value.from_port
          to_port = each.value.to_port
          protocol = each.value.protocol
          cidr_blocks = each.value.cidr_blocks
          description = each.value.description
          

     }

     tags = var.security_group_tags

}