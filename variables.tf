variable "vpc_name" {
    type = string
    
}

variable "vpc_tags" {
    type = map
    default = {}

}

variable "vpc_cidr_block" {
     type = string
   
}

variable "igw_tags" {
    type = map
    default = {}

}

variable "subnet_cidr_pub" {
     type = list
     validation {
       condition = (
        length(var.subnet_cidr_pub) == 2
       )
       error_message = "Public Subnet CIDR block Range doesnot meets the requirment"

     }
   
}

variable "pub_subnet_tags" {
    type = map
    default = {}
  
}

variable "route_tags" {
    type = map
    default = {}
  
}

variable "priv_subnet_tags" {
    type = map
    default = {}
  
}

variable "subnet_cidr_priv" {
     type = list
     validation {
       condition = (
        length(var.subnet_cidr_priv) == 2
       )
       error_message = "Private Subnet CIDR block Range doesnot meets te requirment"

     }
   
}

variable "eip_tags" {
    type = map
    default = {}
  
}

variable "nat_tags" {
    type = map
    default = {}
  
}

variable "security_group_name" {
    type = string
    
  
}

variable "security_group_description" {
    type = string
    default = "Security Group"
    
  
}

variable "ingress_nonprod" {
    type = map
       
  
}
variable "egress_nonprod" {
    type = map
       
  
}
variable "security_group_tags" {
    type = map
       
  
}
