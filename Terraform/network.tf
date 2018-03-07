resource "google_compute_network" "lenken-network-tf" {
  name = "${var.env_name}-lenken-network-tf"
}

resource "google_compute_subnetwork" "lenken-private-subnetwork-tf" {
  name = "${var.env_name}-lenken-private-subnetwork-tf"
  region = "${var.region}"
  network = "${google_compute_network.lenken-network-tf.self_link}"
  ip_cidr_range = "${var.ip_cidr_range}"
}