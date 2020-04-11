module "nat" {
  source     = "./modules/cloud-nat"
  region     = var.region
  name    = "cloud-nat"
}

module "master01" {
  source        = "./modules/instance"
  instance_name = "master01"
  instance_machine_type = "n1-standard-2"
  instance_zone = "${var.region}-a"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["k8smaster"]
  startup_script = ""
}
module "master02" {
  source        = "./modules/instance"
  instance_name = "master02"
  instance_machine_type = "n1-standard-2"
  instance_zone = "${var.region}-b"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["k8smaster"]
  startup_script = ""
}
module "master03" {
  source        = "./modules/instance"
  instance_name = "master03"
  instance_machine_type = "n1-standard-2"
  instance_zone = "${var.region}-c"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["k8smaster"]
  startup_script = ""
}

module "node01" {
  source        = "./modules/instance"
  instance_name = "node01"
  instance_machine_type = "n1-standard-2"
  instance_zone = "${var.region}-a"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["k8sworker"]
  startup_script = ""
}

module "node02" {
  source        = "./modules/instance"
  instance_name = "node02"
  instance_machine_type = "n1-standard-2"
  instance_zone = "${var.region}-b"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["k8sworker"]
  startup_script = ""
}

module "masterlb" {
  source        = "./modules/instance-external"
  instance_name = "masterlb"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-a"
  instance_image = "centos-7-v20191014"
  tags = ["k8sloadbalancer"]
  subnet_name = "default"
  startup_script = ""
  scopes = []
}

module "bastion" {
  source        = "./modules/instance-external"
  instance_name = "bastion"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-a"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  startup_script = ""
  tags = ["bastion"]
  scopes = ["compute-rw","storage-rw"]
}

module "api-server-6443" {
  name        = "api-server-6443"
  source        = "./modules/firewall"
  source_ranges = var.source_ranges
  tcp_ports = ["6443"]
  target_tags = ["k8sloadbalancer"]
}

module "bastion-ssh" {
  name        = "bastion-ssh"
  source        = "./modules/firewall"
  source_ranges = var.source_ranges
  tcp_ports = ["22"]
  target_tags = ["bastion"]
}
