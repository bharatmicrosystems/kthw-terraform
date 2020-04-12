VIP=$1
sed -i "s/#VIP/${VIP}/g" assign-vip.service
sudo cp -a assign-vip.service /etc/systemd/system/assign-vip.service
sudo chmod +x assign-vip.sh
sudo mv assign-vip.sh /usr/bin/assign-vip.sh
sudo systemctl daemon-reload
sudo systemctl start assign-vip
sudo systemctl enable assign-vip
