// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("${var.credential_file}")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

// Configure Terraform Backend
terraform {
  backend "gcs" {
    credentials = "./shared/account.json"
  }
}

// Retrieves state meta data from a remote backend 
data "terraform_remote_state" "lenken" {
  backend = "gcs"
  config {
    bucket = "lenken-tf-state"
    project = "${var.project_id}"
    credentials = "${file("${var.credential_file}")}"
  }
}
