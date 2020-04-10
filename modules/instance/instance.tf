resource "google_compute_instance" "main" {
  name         = var.instance_name
  machine_type = var.instance_machine_type
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    access_config {
    }
  }
  metadata_startup_script = var.startup_script

  service_account {
    scopes = ["storage-rw"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_firewall" "default" {
  name    = "allow-tcp"
  network = "default"
  source_ranges = var.source_ranges
  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
}
