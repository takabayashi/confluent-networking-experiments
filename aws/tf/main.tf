terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_default_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.env_prefix}vpc"
  }
}

resource "aws_subnet" "main" {
  for_each          = toset(var.aws_default_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = each.key

  tags = {
    Name = "${var.env_prefix}subnet"
  }
}

resource "aws_vpc_endpoint" "main" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.vpce.us-east-2.vpce-svc-013e133da40f09f35"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.main : subnet.id]

  tags = {
    Name = "${var.env_prefix}privatelink"
  }
}

# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "${var.env_prefix}igw"
#   }
# }

# resource "aws_route_table" "main" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = {
#     Name = "${var.env_prefix}route-table"
#   }
# }

# resource "aws_route_table_association" "main" {
#   subnet_id      = aws_subnet.main.id
#   route_table_id = aws_route_table.main.id
# }
