output "enviroment_id" {
  value = confluent_environment.environment.id
}

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

output "private_link_endpoint_service_name" {
  value = confluent_private_link_attachment.aws.resource_name
}

output "private_link_endpoint_dns_domain_name" {
  value = confluent_private_link_attachment.aws.dns_domain
}

output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.main.id
}

output "proxy_public_dns" {
  value = aws_instance.proxy.public_dns
}

output "proxy_public_ip" {
  value = aws_instance.proxy.public_ip
}
