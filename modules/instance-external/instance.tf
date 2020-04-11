resource "google_compute_instance" "main" {
  name         = var.instance_name
  machine_type = var.instance_machine_type
  zone         = var.instance_zone

  tags = var.tags

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
    scopes = var.scopes
  }

  allow_stopping_for_update = true
}
