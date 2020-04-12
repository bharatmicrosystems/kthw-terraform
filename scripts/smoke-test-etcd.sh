sudo ETCDCTL_API=3 /usr/local/bin/etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/etcd.pem \
  --key=/etc/etcd/etcd-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C
  
