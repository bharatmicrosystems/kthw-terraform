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
  startup_script = "sudo yum install -y git wget && wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/bin/"
  tags = ["bastion"]
  scopes = ["compute-rw","storage-rw"]
}

module "api-server-6443" {
  name        = "api-server-6443"
  source        = "./modules/firewall"
  source_ranges = var.source_ranges
  source_tags = ["k8sworker","k8smaster"]
  tcp_ports = ["6443"]
  udp_ports = []
  target_tags = ["k8sloadbalancer"]
}

module "bastion-ssh" {
  name        = "bastion-ssh"
  source        = "./modules/firewall"
  source_ranges = var.source_ranges
  source_tags = []
  tcp_ports = ["22"]
  udp_ports = []
  target_tags = ["bastion"]
}

module "master-apiserver" {
  name        = "master-apiserver"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sloadbalancer","k8sworker"]
  tcp_ports = ["6443"]
  udp_ports = []
  target_tags = ["k8smaster"]
}

module "master-etcd" {
  name        = "master-etcd"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8smaster"]
  tcp_ports = ["2379-2380"]
  udp_ports = []
  target_tags = ["k8smaster"]
}

module "allow-ssh-from-bastion" {
  name        = "master-ssh"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["bastion"]
  target_tags = []
  tcp_ports = ["22"]
  udp_ports = []
}

module "worker-kubelet" {
  name        = "worker-kubelet"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8smaster"]
  tcp_ports = ["10250"]
  udp_ports = []
  target_tags = ["k8sworker"]
}

module "worker-nodeport" {
  name        = "worker-nodeport"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sloadbalancer","k8smaster"]
  tcp_ports = ["30000-32767"]
  udp_ports = []
  target_tags = ["k8sworker"]
}

module "worker-allow-weave-coredns" {
  name        = "worker-allow-weave-coredns"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sworker"]
  tcp_ports = ["6781-6783"]
  udp_ports = ["6783","6784"]
  target_tags = ["k8sworker"]
}
