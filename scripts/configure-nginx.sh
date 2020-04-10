sudo rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo yum install -y nginx telnet
sudo setenforce 0
sudo sed -i 's/enforcing/permissive/g' /etc/selinux/config
sudo systemctl enable nginx
sudo mkdir -p /etc/nginx/tcpconf.d
sudo chmod 666 /etc/nginx/nginx.conf
sudo echo 'include /etc/nginx/tcpconf.d/*;' >> /etc/nginx/nginx.conf
sudo chmod 644 /etc/nginx/nginx.conf
sudo cat << EOF | sudo tee /etc/nginx/tcpconf.d/kubernetes.conf
stream {
    upstream kubernetes {
        server master01:6443;
        server master02:6443;
	server master03:6443;
    }

    server {
        listen 6443;
        proxy_pass kubernetes;
    }
}
EOF
sudo systemctl start nginx
curl -k https://localhost:6443/version
