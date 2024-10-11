# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.5.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.cflt_api_key    # optionally use CONFLUENT_CLOUD_API_KEY env var
  cloud_api_secret = var.cflt_api_secret # optionally use CONFLUENT_CLOUD_API_SECRET env var
}

resource "confluent_environment" "environment" {
  display_name = "${var.env_prefix}cluster"
}

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
    vpc_endpoint_id = "vpce-0d04d99cff04f0e45"
  }

  private_link_attachment {
    id = confluent_private_link_attachment.aws.id
  }
}

# resource "confluent_network" "aws-private-link" {
#   display_name     = "${var.env_prefix}privatelink"
#   cloud            = "AWS"
#   region           = var.aws_default_region
#   connection_types = ["PRIVATELINK"]
#   #zones            = var.aws_default_zones
#   environment {
#     id = confluent_environment.environment.id
#   }
# }

# resource "confluent_network_link_service" "aws_nls" {
#   display_name = "AWS Private Link network link service"
#   environment {
#     id = confluent_environment.environment.id
#   }
#   network {
#     id = confluent_network.aws-private-link.id
#   }

#   accept {
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
# }

resource "confluent_kafka_cluster" "enterprise" {
  display_name = "enterprise_cluster"
  availability = "MULTI_ZONE"
  cloud        = "AWS"
  region       = var.aws_default_region

  enterprise {}

  environment {
    id = confluent_environment.environment.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_service_account" "app-manager" {
  display_name = "${var.env_prefix}app-manager"
  description  = "Service account to manage Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.enterprise.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "${var.env_prefix}app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"

  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.enterprise.id
    api_version = confluent_kafka_cluster.enterprise.api_version
    kind        = confluent_kafka_cluster.enterprise.kind

    environment {
      id = confluent_environment.environment.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin,
  ]
}

resource "confluent_kafka_topic" "my_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.enterprise.id
  }
  topic_name    = "my_topic"
  rest_endpoint = confluent_kafka_cluster.enterprise.rest_endpoint

  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}
