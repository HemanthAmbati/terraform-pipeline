variable "string" {
    type = string
    default = "arn:aws:clouddirectory:us-west-2:accountId:schema/development/SchemaName"

    
}

variable "vpc_tags" {
    type = map
    default = {
        Name = "Internal"
        Env = "Dev"
    }

}
