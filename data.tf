data "aws_availability_zones" "available" { # to query the availability zones in the provider
  state = "available"
}
data "aws_vpc" "default" {
  default = true
}

#querying default vpc main route table
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}