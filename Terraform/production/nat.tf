resource "google_compute_instance" "lenken-nat-server" {
  name         = "${var.env_name}-lenken-nat-server"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  allow_stopping_for_update = true

  tags = ["nat","nat-egress","nat-ingress","allow-internal","allow-ssh", "http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "${var.lenken-nat-base}"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.lenken-public-subnetwork-tf.self_link}"

    access_config {
      nat_ip = "${var.lenken_nat_ip}"
    }
  }

  can_ip_forward = "true"

  metadata {
    // .env files
  }

  metadata_startup_script = "echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward && sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

  service_account {
    email = "${var.service_account_email}"
    scopes = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.read", "https://www.googleapis.com/auth/logging.write"]
  }
}