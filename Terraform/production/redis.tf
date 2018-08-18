resource "google_compute_instance" "lenken-redis-server" {
  name         = "${var.env_name}-lenken-redis-server"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags = ["allow-redis", "private-instance", "http-server", "https-server", "allow-internal","allow-ssh"]

  boot_disk {
    initialize_params {
      image = "lenken-redis-image"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.lenken-private-subnetwork-tf.name}"

    address = "10.0.1.6"
    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    // .env files
  }

  service_account {
    email = "${var.service_account_email}"
    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.read", "https://www.googleapis.com/auth/logging.write"]
  }
}