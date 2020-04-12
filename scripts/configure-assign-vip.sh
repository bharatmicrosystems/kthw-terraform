sudo rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo yum install -y nginx telnet
sudo systemctl restart nginx
sudo cp -a assign-vip.service /etc/systemd/system/assign-vip.service
sudo chmod +x assign-vip.sh
sudo mv assign-vip.sh /usr/bin/assign-vip.sh
sudo systemctl daemon-reload
sudo systemctl start assign-vip
sudo systemctl enable assign-vip
