ETCD_HOSTS=$1
LOAD_BALANCER=$2
sudo yum install -y wget
wget  "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"
{
  tar -xvf etcd-v3.4.0-linux-amd64.tar.gz
  sudo mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/
}
#Configure etcd
{
  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo cp ca.pem etcd-key.pem etcd.pem /etc/etcd/
}
INTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)
ETCD_NAME=$(hostname -s)
#Build the initial-clutser String
for instance in $(echo $ETCD_HOSTS | tr ',' ' '); do
  INITIAL_CLUSTER_STRING="${INITIAL_CLUSTER_STRING},${instance}=https://${instance}:2380"
done
INITIAL_CLUSTER_STRING=$(echo $INITIAL_CLUSTER_STRING | sed 's/^,//')
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/etcd.pem \\
  --key-file=/etc/etcd/etcd-key.pem \\
  --peer-cert-file=/etc/etcd/etcd.pem \\
  --peer-key-file=/etc/etcd/etcd-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${LOAD_BALANCER}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster $INITIAL_CLUSTER_STRING \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
  sudo systemctl restart etcd
}
sudo ETCDCTL_API=3 /usr/local/bin/etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/etcd.pem \
  --key=/etc/etcd/etcd-key.pem
