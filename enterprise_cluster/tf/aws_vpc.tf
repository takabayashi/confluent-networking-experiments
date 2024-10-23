resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

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

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}security_group"
  }
}

resource "aws_vpc_endpoint" "main" {
  vpc_id             = aws_vpc.main.id
  service_name       = confluent_private_link_attachment.aws.aws[0].vpc_endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for subnet in aws_subnet.main : subnet.id]
  security_group_ids = [aws_security_group.main.id]

  tags = {
    Name = "${var.env_prefix}privatelink"
  }

  depends_on = [confluent_private_link_attachment.aws]
}
