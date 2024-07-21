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

# resource "aws_eip" "nat" {
#      domain = "vpc"
#      tags = merge(var.eip_tags,{
#                Name = "${var.vpc_name}_Pub"
#           })
# }

# resource "aws_nat_gateway" "nat_eip" {
#      allocation_id = "${aws_eip.nat.id}"
#      subnet_id = "${aws_subnet.public[0].id}"
#      tags = merge(var.nat_tags,{
#                Name = "${var.vpc_name}_Pub"
#           })
# }

#Security WORLD

resource "aws_security_group" "inbound_noprod" {
     name = var.security_group_name
     description = var.security_group_description
     vpc_id = aws_vpc.nonprod.id

     dynamic "ingress" {
          for_each = var.ingress_nonprod
          content {
               from_port = ingress.value.from_port
               to_port = ingress.value.to_port
               protocol = ingress.value.protocol
               cidr_blocks = ingress.value.cidr_blocks
               description = ingress.value.description
            
          }
          
     }

      dynamic "egress" {
          for_each = var.ingress_nonprod
          content {
            from_port = egress.value.from_port
             to_port = egress.value.to_port
             protocol = egress.value.protocol
             cidr_blocks = egress.value.cidr_blocks
             description = egress.value.description
          }
          
     }

     tags = var.security_group_tags

}
resource "aws_key_pair" "provision" {
     key_name = "terraform_pub"
     public_key = file("H:\\terraform_pub.pub")
}

resource "aws_instance" "inbound" {
     ami = var.inbound_ami
     instance_type = var.ec2_type
     key_name = aws_key_pair.provision.key_name
     user_data = "${file("scripts/docker.sh")}"
     security_groups = [aws_security_group.inbound_noprod.id]
     tags = merge(var.security_group_tags, {
          Name = "Docker-test"
          })
     provisioner "local-exec" {
          command = "echo the server IP ADDRESS is ${self.public_ip} > public_ip.txt"
       
     }


} 