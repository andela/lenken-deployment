// Begin HTTP
resource "google_compute_global_forwarding_rule" "lenken-http" {
  name       = "${var.env_name}-lenken-http"
  ip_address = "${var.reserved_env_ip}"
  target     = "${google_compute_target_http_proxy.lenken-http-proxy.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "lenken-http-proxy" {
  name        = "${var.env_name}-lenken-proxy"
  url_map     = "${google_compute_url_map.lenken-http-url-map.self_link}"
}

// Begin HTTPS
resource "google_compute_global_forwarding_rule" "lenken-https" {
  name       = "${var.env_name}-lenken-https"
  ip_address = "${var.reserved_env_ip}"
  target     = "${google_compute_target_https_proxy.lenken-https-proxy.self_link}"
  port_range = "443"
}

// Create SSL certificate
resource "google_compute_ssl_certificate" "lenken-ssl-certificate" {
  name_prefix = "lenken-certificate-"
  description = "Lenken HTTPS certificate"
  private_key = "${file("./shared/andela_key.key")}"
  certificate = "${file("./shared/andela_certificate.crt")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_https_proxy" "lenken-https-proxy" {
  name = "${var.env_name}-lenken-https-proxy"
  url_map = "${google_compute_url_map.lenken-http-url-map.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.lenken-ssl-certificate.self_link}"]
}

resource "google_compute_url_map" "lenken-http-url-map" {
  name            = "${var.env_name}-lenken-url-map"
  default_service = "${google_compute_backend_service.lenken-frontend-backendservice.self_link}"

  host_rule {
    hosts        = ["${var.reserved_env_ip}"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.lenken-frontend-backendservice.self_link}"

     path_rule {
      paths   = ["/api"]
      service = "${google_compute_backend_service.lenken-api-backendservice.self_link}"
    }

     path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.lenken-frontend-backendservice.self_link}"
    }
  }
}

resource "google_compute_firewall" "lenken-internal-firewall" {
  name = "${var.env_name}-lenken-internal-network"
  network = "${google_compute_network.lenken-network-tf.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  source_ranges = ["${var.ip_cidr_range}"]
}

resource "google_compute_firewall" "lenken-public-firewall" {
  name = "${var.env_name}-lenken-public-firewall"
  network = "${google_compute_network.lenken-network-tf.name}"

  allow {
    protocol = "tcp"
    ports = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.env_name}-lenken-lb"]
}

resource "google_compute_firewall" "lenken-allow-healthcheck-firewall" {
  name = "${var.env_name}-lenken-allow-healthcheck-firewall"
  network = "${google_compute_network.lenken-network-tf.name}"

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_ranges = ["35.227.0.0/16","0.0.0.0/0"]
  target_tags = ["${var.env_name}-lenken-backend", "lenken-backend", "${var.env_name}-lenken-frontend", "lenken-frontend"]
}