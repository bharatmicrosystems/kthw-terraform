variable "source_ranges" {
  type    = list(string)
}
variable "tcp_ports" {
  type    = list(string)
}
variable "udp_ports" {
  type    = list(string)
}
variable "name" {}
variable "target_tags" {
  type    = list(string)
}
variable "source_tags" {
  type    = list(string)
}
