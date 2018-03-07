variable "credential_file" {
  type = "string"
  default = "./shared/account.json"
}

variable "project_id" {
  type = "string"
  default = "andela-learning"

}

variable "region" {
  type = "string"
  default = "europe-west1"
}

variable "zone" {
  type = "string"
  default = "europe-west1-b"
}

variable "env_name" {
  type = "string"
  default = "sandbox"
}

variable "ip_cidr_range" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "machine_type" {
  type = "string"
  default = "n1-standard-1"
}

variable "small_machine_type" {
  type = "string"
  default = "g1-small"
}

variable "base_image" {
  type = "string"
  default = "ubuntu-1604-xenial-v20170815a"
}

variable "lenken_disk_image" {
  type = "string"
  default = "test"
}

variable "lenken_disk_type" {
  type = "string"
  default = "pd-ssd"
}

variable "lenken_disk_size" {
  type = "string"
  default = "10"
}

variable "service_account_email" {
  type = "string"
  default = "lenken-sandbox-auth@andela-learning.iam.gserviceaccount.com"
}

variable "max_instances" {
  type = "string"
  default = "4"
}

variable "min_instances" {
  type = "string"
  default = "2"
}

variable "request_path" {
  type = "string"
  default = "/"
}

variable "check_interval_sec" {
  type = "string"
  default = "2"
}

variable "unhealthy_threshold" {
  type = "string"
  default = "2"
}

variable "healthy_threshold" {
  type = "string"
  default = "2"
}

variable "timeout_sec" {
  type = "string"
  default = "1"
}

variable "reserved_env_ip" {}

