// instance.tf variables
variable "instance_name" {}
variable "instance_machine_type" {}
variable "instance_zone" {}
variable "instance_image" {}
variable "subnet_name" {}
variable "startup_script" {}
variable "source_ranges" {
  type    = list(string)
}
variable "tcp_ports" {
  type    = list(string)
}
