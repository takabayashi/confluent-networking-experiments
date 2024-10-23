resource "aws_route53_zone" "private" {
  name = confluent_private_link_attachment.aws.dns_domain

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name = "${var.env_prefix}private_dns_zone"
  }
}

resource "aws_route53_record" "entries" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "*"
  type    = "CNAME"
  ttl     = 60

  records = [aws_vpc_endpoint.main.dns_entry.0.dns_name]
}
