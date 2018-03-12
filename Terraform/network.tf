resource "google_compute_network" "lenken-network-tf" {
  name = "${var.env_name}-lenken-network-tf"
}

resource "google_compute_subnetwork" "lenken-private-subnetwork-tf" {
  name = "${var.env_name}-lenken-private-subnetwork-tf"
  region = "${var.region}"
  network = "${google_compute_network.lenken-network-tf.self_link}"
  ip_cidr_range = "${var.ip_cidr_range}"
}

resource "google_compute_subnetwork" "lenken-public-subnetwork-tf" {
  name = "${var.env_name}-lenken-public-subnetwork-tf"
  region = "${var.region}"
  network = "${google_compute_network.lenken-network-tf.self_link}"
  ip_cidr_range = "${var.ip_cidr_range_public}"
}

resource "google_compute_route" "lenken-route" {
  name        = "${var.env_name}-lenken-route"
  dest_range  = "0.0.0.0/0"
  network     = "${google_compute_network.lenken-network-tf.self_link}"
  next_hop_instance = "${google_compute_instance.lenken-nat-server.self_link}"
  priority    = 800
  tags = ["private-instance"]
}