data "external" "my_public_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

locals {
  cluster_hostname = regex("(.*):", confluent_kafka_cluster.enterprise.bootstrap_endpoint)[0]
}
