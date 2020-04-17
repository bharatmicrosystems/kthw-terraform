// instance.tf variables
variable "instance_name" {}
variable "instance_machine_type" {}
variable "instance_zone" {}
variable "instance_image" {}
variable "subnet_name" {}
variable "startup_script" {}
variable "tags" {
  type = list(string)
}
variable "scopes" {
  type = list(string)
}
