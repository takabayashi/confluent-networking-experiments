
resource "confluent_private_link_attachment" "aws" {
  display_name = "${var.env_prefix}privatelink-attachment"
  cloud        = "AWS"
  region       = var.aws_default_region
  environment {
    id = confluent_environment.environment.id
  }
}

resource "confluent_private_link_attachment_connection" "aws" {
  display_name = "${var.env_prefix}privatelink-connection"
  environment {
    id = confluent_environment.environment.id
  }

  aws {
    vpc_endpoint_id = aws_vpc_endpoint.main.id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.aws.id
  }

  depends_on = [aws_subnet.main]
}
