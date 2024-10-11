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
  type    = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
