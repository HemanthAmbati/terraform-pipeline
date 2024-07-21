locals {
    
    tags_vpc = join ("/", [split(":", var.string)])
}