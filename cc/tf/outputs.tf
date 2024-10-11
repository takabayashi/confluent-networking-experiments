output "cluster_id" {
  value = confluent_kafka_cluster.enterprise.id
}

output "cluster_name" {
  value = confluent_kafka_cluster.enterprise.display_name
}

output "cluster_bootstrap_servers" {
  value = confluent_kafka_cluster.enterprise.bootstrap_endpoint
}

output "cluster_api_endpoint" {
  value = confluent_kafka_cluster.enterprise.rest_endpoint
}

output "topic_name" {
  value = confluent_kafka_topic.my_topic.topic_name
}

output "cluster_api_key" {
  value = confluent_api_key.app-manager-kafka-api-key.id
}

output "cluster_api_secret" {
  value = nonsensitive(confluent_api_key.app-manager-kafka-api-key.secret)
}

# output "private_link_endpoint_service_name" {
#   value = confluent_network_link_service.aws_nls.resource_name
# }
