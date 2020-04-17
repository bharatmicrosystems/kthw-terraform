#!/bin/bash
sudo systemctl enable corosync.service pacemaker.service
sudo mkdir -p /usr/lib/ocf/resource.d/gcp
sudo mv gcp-failoverd.sh /usr/lib/ocf/resource.d/gcp/gcp-failoverd
sudo mv gcp-assign-vip.sh /usr/bin/gcp-assign-vip.sh
sudo chmod +x /usr/lib/ocf/resource.d/gcp/gcp-failoverd
sudo chmod +x /usr/bin/gcp-assign-vip.sh
sudo chown -R root:root /usr/lib/ocf/resource.d/gcp
sudo chown root:root /usr/bin/gcp-assign-vip.sh
sudo pcs resource create GCPFailoverd ocf:gcp:gcp-failoverd#PARAMS
sudo pcs status
