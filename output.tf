output "list_of_total_avzs" {
    value = local.list
}

output "list_of_working_avzs" {
    value = local.selected_azs
}

output "list_of_keys_avzs" {
    value = local.tails
}

output "vpc_id" {
    value = aws_vpc.nonprod.id
}

output "public_subnets" {
    value = aws_subnet.public[*].id
}

output "private_subnets" {
    value = aws_subnet.private[*].id
}

output "rds_security_id" {
    value = aws_security_group.inbound_noprod.id
}

output "Ec2_instance_id" {
    value = aws_instance.inbound.id
}

