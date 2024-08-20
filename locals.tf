locals {
  resource_name = "${var.project_name}-${var.environment}"
  az_names = slice(data.aws_availability_zones.available.names, 0,2) 
}

# slice function is used to cut the data into req info
# in the slice function will able to query the aws_availability_zones into two zones i.e us-east-1a,us-east-1b
