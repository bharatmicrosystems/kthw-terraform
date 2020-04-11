resource "google_compute_firewall" "default" {
  name    = var.name
  network = "default"
  source_ranges = var.source_ranges
  target_tags = var.target_tags
  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
}
