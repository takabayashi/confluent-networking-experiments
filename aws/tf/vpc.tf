resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.env_prefix}vpc"
  }
}

resource "aws_subnet" "main" {
  for_each          = { for z in var.aws_default_zones : z.zone => { zone = z.zone, cidr = z.cidr } }
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value.zone
  cidr_block        = each.value.cidr

  tags = {
    Name = "${var.env_prefix}subnet"
  }
}

resource "aws_vpc_endpoint" "main" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.s3"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for subnet in aws_subnet.main : subnet.id]

  tags = {
    Name = "${var.env_prefix}privatelink"
  }
}
