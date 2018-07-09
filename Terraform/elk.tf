// Lenken ELK Instance template
resource "google_compute_instance" "lenken-elk-instance" {
  name = "lenken-elk-instance"
  machine_type = "${var.elk_machine_type}"
  zone = "${var.zone}"

  tags = ["lenken-backend", "http-server", "https-server", "default-allow-elk"]

  network_interface {
    subnetwork = "${google_compute_subnetwork.lenken-public-subnetwork-tf.self_link}"
    access_config {
      nat_ip = "${var.lenken_elk_ip}"
    }
  }

  boot_disk {
    initialize_params {
      image = "${var.lenken_elk_image}"
      size = "${var.lenken_elk_disk_size}"
      disk_type = "${var.lenken_disk_type}"
    }
    auto_delete = true
  }

  metadata {
    // all .env file should be here
  }

  # the email is the service account email whose service keys have all the roles suffiecient enough
  # for the project to interract with all the APIs it does interract with.
  # the scopes are those that we need for logging and monitoring, they are a must for logging to
  # be carried out.
  # the whole service account argument is required for identity and authentication reasons, if it is
  # not included here, the default service account is used instead.
  service_account {
    email = "${var.service_account_email}"
    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.read", "https://www.googleapis.com/auth/logging.write"]
  }
}
