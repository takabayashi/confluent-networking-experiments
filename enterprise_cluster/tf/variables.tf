variable "env_prefix" {
  type    = string
  default = "ntwk_experiments_"
}
variable "cflt_api_key" {
  type      = string
  sensitive = true
}

variable "cflt_api_secret" {
  type      = string
  sensitive = true
}

variable "cflt_default_env" {
  type      = string
  sensitive = false
}

variable "aws_account_id" {
  type      = string
  sensitive = true
}

variable "aws_default_region" {
  type    = string
  default = "sa-east-1"
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "aws_default_zones" {
  type = list(object({
    zone = string
    cidr = string
  }))
  default = [{ "zone" = "sa-east-1a", cidr = "10.0.0.0/24" }, { "zone" = "sa-east-1b", cidr = "10.0.1.0/24" }, { "zone" = "sa-east-1c", cidr = "10.0.2.0/24" }]
}

variable "aws_default_ami" {
  type = string
  # default = "ami-0c55b159cbfafe1f0" us-east-2
  default = "ami-036f48ec20249562a" # sa-east-1
}



