locals {
  list         = data.aws_availability_zones.azs_info.names
  selected_azs = slice(local.list, 0, 2)
  count        = length(local.selected_azs)
  tails        = [for az in local.selected_azs : split("-", az)[2]]
}