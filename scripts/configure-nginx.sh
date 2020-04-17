masters=$1
etcds=$2
sudo rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo yum install -y nginx telnet
sudo setenforce 0
sudo sed -i 's/enforcing/permissive/g' /etc/selinux/config
#sudo systemctl enable nginx
sudo mkdir -p /etc/nginx/tcpconf.d
sudo chmod 666 /etc/nginx/nginx.conf
sudo sed -i "s/1024/999999/g" /etc/nginx/nginx.conf
sudo cat << EOF | sudo tee /etc/nginx/conf.d/healthz.conf
server {
    listen 127.0.0.1:80;
    server_name 127.0.0.1;

    location /nginx_status {
        stub_status;
    }
}
EOF
sudo echo 'stream {' >> /etc/nginx/nginx.conf
sudo echo '    include /etc/nginx/tcpconf.d/*;' >> /etc/nginx/nginx.conf
sudo echo '}' >> /etc/nginx/nginx.conf
sudo chmod 644 /etc/nginx/nginx.conf
sudo cat << EOF | sudo tee /etc/nginx/tcpconf.d/kubernetes.conf
upstream kubernetes {
    #ph
}

server {
    listen 6443;
    proxy_pass kubernetes;
}
EOF

sudo cat << EOF | sudo tee /etc/nginx/tcpconf.d/etcd.conf
upstream etcd {
    #ph
}

server {
    listen 2379;
    proxy_pass etcd;
}
EOF

for instance in $(echo $masters | tr ',' ' '); do
  sudo sed -i "s/#ph/server ${instance}:6443;\n    #ph/g" /etc/nginx/tcpconf.d/kubernetes.conf
done

for instance in $(echo $etcds | tr ',' ' '); do
  sudo sed -i "s/#ph/server ${instance}:2379;\n    #ph/g" /etc/nginx/tcpconf.d/etcd.conf
done

#sudo systemctl start nginx
#sudo systemctl status nginx
