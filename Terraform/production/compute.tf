// Backend resource for Lenken Frontend
resource "google_compute_backend_service" "lenken-frontend-backendservice" {
  name        = "${var.env_name}-lenken-frontend-backendservice"
  description = "Lenken Frontend Backendservices"
  port_name   = "customhttp"
  protocol    = "HTTP"
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.lenken-frontend-group-manager.instance_group}"
  }

  session_affinity = "GENERATED_COOKIE"

  health_checks = ["${google_compute_health_check.lenken-frontend-healthcheck.self_link}"]
}

// Backend resource for Lenken API
resource "google_compute_backend_service" "lenken-api-backendservice" {
  name        = "${var.env_name}-lenken-api-backendservice"
  description = "Lenken API Backendservices"
  port_name   = "customhttp"
  protocol    = "HTTP"
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.lenken-api-group-manager.instance_group}"
  }

  session_affinity = "GENERATED_COOKIE"

  health_checks = ["${google_compute_health_check.lenken-api-healthcheck.self_link}"]
}

// Lenken Frontend instance group
resource "google_compute_instance_group_manager" "lenken-frontend-group-manager" {
  name = "${var.env_name}-lenken-frontend-group-manager"
  base_instance_name = "${var.env_name}-lenken-frontend-instance"
  instance_template = "${google_compute_instance_template.lenken-frontend-template.self_link}"
  zone = "${var.zone}"
  update_strategy = "NONE"

  named_port {
    name = "customhttps"
    port = 8080
  }
}

// Lenken Backend instance group
resource "google_compute_instance_group_manager" "lenken-api-group-manager" {
  name = "${var.env_name}-lenken-api-group-manager"
  base_instance_name = "${var.env_name}-lenken-api-instance"
  instance_template = "${google_compute_instance_template.lenken-api-template.self_link}"
  zone = "${var.zone}"
  update_strategy = "NONE"

  named_port {
    name = "customhttps"
    port = 8080
  }
}

// Lenken Frontend Instance template
resource "google_compute_instance_template" "lenken-frontend-template" {
  name_prefix = "${var.env_name}-lenken-frontend-template"
  machine_type = "${var.machine_type}"
  region = "${var.region}"
  description = "Lenken Frontend base template"
  instance_description = "Instance created from base template"
  depends_on = ["google_compute_instance.lenken-redis-server"]
  tags = ["${var.env_name}-lenken-frontend", "lenken-frontend", "private-instance", "http-server", "https-server"]

  network_interface {
    subnetwork = "${google_compute_subnetwork.lenken-private-subnetwork-tf.name}"
    access_config {}
  }

  disk {
    source_image = "${var.lenken_frontend_image}"
    auto_delete = true
    boot = true
    disk_type = "${var.lenken_disk_type}"
    disk_size_gb = "${var.lenken_disk_size}"
  }

  metadata {
    // all .env file should be here
  }

  lifecycle {
    create_before_destroy = true
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

// Lenken Backend Instance template
resource "google_compute_instance_template" "lenken-api-template" {
  name_prefix = "${var.env_name}-lenken-api-template"
  machine_type = "${var.machine_type}"
  region = "${var.region}"
  description = "Lenken API base template"
  instance_description = "Instance created from base template"
  depends_on = ["google_compute_instance.lenken-redis-server"]
  tags = ["${var.env_name}-lenken-backend", "lenken-backend", "private-instance", "http-server", "https-server"]

  network_interface {
    subnetwork = "${google_compute_subnetwork.lenken-private-subnetwork-tf.name}"
    access_config {}
  }

  disk {
    source_image = "${var.lenken_backend_image}"
    auto_delete = true
    boot = true
    disk_type = "${var.lenken_disk_type}"
    disk_size_gb = "${var.lenken_disk_size}"
  }

  metadata {
    // all .env file should be here
  }

  lifecycle {
    create_before_destroy = true
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

// Lenken Frontend Auto scaling
resource "google_compute_autoscaler" "lenken-frontend-autoscaler" {
  name = "${var.env_name}-lenken-frontend-autoscaler"
  zone = "${var.zone}"
  target = "${google_compute_instance_group_manager.lenken-frontend-group-manager.self_link}"
  autoscaling_policy = {
    max_replicas = "${var.max_instances}"
    min_replicas = "${var.min_instances}"
    cooldown_period = 60
    cpu_utilization {
      target = 0.7
    }
  }
}

// Lenken Backend Auto scaling
resource "google_compute_autoscaler" "lenken-api-autoscaler" {
  name = "${var.env_name}-lenken-api-autoscaler"
  zone = "${var.zone}"
  target = "${google_compute_instance_group_manager.lenken-api-group-manager.self_link}"
  autoscaling_policy = {
    max_replicas = "${var.max_instances}"
    min_replicas = "${var.min_instances}"
    cooldown_period = 60
    cpu_utilization {
      target = 0.7
    }
  }
}

// Lenken frontend healthcheck
resource "google_compute_health_check" "lenken-frontend-healthcheck"{
  name = "${var.env_name}-lenken-frontend-healthcheck"

  
  // request_path = "${var.request_path}"
  check_interval_sec = "${var.check_interval_sec}"
  timeout_sec = "${var.timeout_sec}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  healthy_threshold = "${var.healthy_threshold}"

  tcp_health_check {
    port = "80"
  }
}

// Lenken api healthcheck
resource "google_compute_health_check" "lenken-api-healthcheck"{
  name = "${var.env_name}-lenken-api-healthcheck"
  // request_path = "${var.request_path}"
  check_interval_sec = "${var.check_interval_sec}"
  timeout_sec = "${var.timeout_sec}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  healthy_threshold = "${var.healthy_threshold}"

  tcp_health_check {
    port = "80"
  }
}

