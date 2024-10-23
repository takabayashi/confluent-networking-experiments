
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
    confluent_role_binding.app-manager-kafka-cluster-admin, aws_instance.proxy
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
