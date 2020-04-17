loadbalancers=$1
masters=$2
etcds=$3
internal_vip=$4
external_vip=$5
for instance in $(echo $loadbalancers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip configure-nginx.sh $instance:~/
  gcloud compute ssh --zone=$ZONE --internal-ip $instance -- "cd ~/ && sh -x configure-nginx.sh $masters $etcds"
done
echo 'Setting up HA between NGINX Load Balancers'
sh -x setup-gcp-failoverd.sh -i $internal_vip -e $external_vip -l $loadbalancers -c "k8scluster" -h ":80\/nginx_status"
sleep 1
