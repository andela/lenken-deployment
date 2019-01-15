variable "credential_file" {
  type = "string"
  default = "./shared/lenken-account.json"
}

variable "project_id" {
  type = "string"
  default = "lenken-app"

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
}

variable "lenken_frontend_image" {
  type = "string"
}

variable "lenken_nat_ip" {
  type = "string"
}

variable "lenken_elk_ip" {
  type = "string"
}

variable "lenken_backend_image" {
  type = "string"
}

variable "lenken-nat-base" {
  type = "string"
}

variable "ip_cidr_range" {
  type = "string"
  default = "10.0.1.0/24"
}


variable "ip_cidr_range_public" {
  type = "string"
  default = "10.0.2.0/24"
}

variable "machine_type" {
  type = "string"
  default = "n1-standard-1"
}

variable "elk_machine_type" {
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

variable "lenken_elk_image" {
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

variable "lenken_elk_disk_size" {
  type = "string"
  default = "10"
}

variable "service_account_email" {
  type = "string"
  default = "134344413520-compute@developer.gserviceaccount.com"
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

variable "db_instance_tier" {
  type = "string"
  default = "db-f1-micro"
}

variable "db_backup_start_time" {
  type = "string"
  default = "00:12"
}

variable "bucket" {}
