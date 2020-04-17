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
  scopes = ["storage-rw"]
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
  scopes = ["storage-rw"]
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
  scopes = ["storage-rw"]
}

module "etcd01" {
  source        = "./modules/instance"
  instance_name = "etcd01"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-a"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["etcd"]
  startup_script = ""
  scopes = ["storage-rw"]
}
module "etcd02" {
  source        = "./modules/instance"
  instance_name = "etcd02"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-b"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["etcd"]
  startup_script = ""
  scopes = ["storage-rw"]
}
module "etcd03" {
  source        = "./modules/instance"
  instance_name = "etcd03"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-c"
  instance_image = "centos-7-v20191014"
  subnet_name = "default"
  tags = ["etcd"]
  startup_script = ""
  scopes = ["storage-rw"]
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
  scopes = ["storage-rw"]
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
  scopes = ["storage-rw"]
}

module "masterlb" {
  source        = "./modules/instance"
  instance_name = "masterlb"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-a"
  instance_image = "centos-7-v20191014"
  tags = ["k8sloadbalancer"]
  subnet_name = "default"
  startup_script = "sudo yum install -y git wget && wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/bin/"
  scopes = ["compute-rw","storage-rw"]
}

module "masterlb-dr" {
  source        = "./modules/instance"
  instance_name = "masterlb-dr"
  instance_machine_type = "n1-standard-1"
  instance_zone = "${var.region}-b"
  instance_image = "centos-7-v20191014"
  tags = ["k8sloadbalancer"]
  subnet_name = "default"
  startup_script = "sudo yum install -y git wget && wget https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/bin/"
  scopes = ["compute-rw","storage-rw"]
}

resource "google_compute_address" "masterlb-internal-vip" {
  name         = "masterlb-internal-vip"
  subnetwork   = "default"
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_address" "masterlb-external-vip" {
  name         = "masterlb-external-vip"
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

module "master-etcdlb" {
  name        = "master-etcdlb"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8smaster"]
  tcp_ports = ["2379"]
  udp_ports = []
  target_tags = ["k8sloadbalancer"]
}

module "internet-bastion-ssh" {
  name        = "bastion-ssh"
  source        = "./modules/firewall"
  source_ranges = var.source_ranges
  source_tags = []
  tcp_ports = ["22"]
  udp_ports = []
  target_tags = ["bastion"]
}

module "apiserverlb-master" {
  name        = "apiserverlb-master"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sloadbalancer"]
  tcp_ports = ["6443"]
  udp_ports = []
  target_tags = ["k8smaster"]
}

module "etcdlb-etcd" {
  name        = "etcdlb-etcd"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sloadbalancer"]
  tcp_ports = ["2379"]
  udp_ports = []
  target_tags = ["etcd"]
}

module "etcd-etcd" {
  name        = "etcd-etcd"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["etcd"]
  tcp_ports = ["2379-2380"]
  udp_ports = []
  target_tags = ["etcd"]
}

module "allow-ssh-from-bastion" {
  name        = "master-ssh"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["bastion"]
  target_tags = []
  tcp_ports = ["22","80"]
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

module "worker-allow-weave" {
  name        = "worker-allow-weave"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sworker"]
  tcp_ports = ["6781-6783"]
  udp_ports = ["6783","6784"]
  target_tags = ["k8sworker"]
}
module "allow-lb-lb" {
  name        = "allow-lb-lb"
  source        = "./modules/firewall"
  source_ranges = []
  source_tags = ["k8sloadbalancer"]
  tcp_ports = []
  udp_ports = ["5404-5406"]
  target_tags = ["k8sloadbalancer"]
}
