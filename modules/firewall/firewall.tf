resource "google_compute_firewall" "default" {
  name    = "allow-tcp"
  network = "default"
  source_ranges = var.source_ranges
  allow {
    protocol = "tcp"
    ports    = var.tcp_ports
  }
}
