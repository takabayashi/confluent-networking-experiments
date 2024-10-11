variable "env_prefix" {
  type    = string
  default = "ntwk_experiments_"
}
variable "aws_account_id" {
  type      = string
  sensitive = true
}
variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_default_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_default_zones" {
  type = list(object({
    zone = string
    cidr = string
  }))
  default = [{ "zone" = "us-east-2a", cidr = "10.0.0.0/24" }, { "zone" = "us-east-2b", cidr = "10.0.1.0/24" }, { "zone" = "us-east-2c", cidr = "10.0.2.0/24" }]
}

variable "aws_default_ami" {
  type    = string
  default = "ami-0c55b159cbfafe1f0"
}
