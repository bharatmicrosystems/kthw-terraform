loadbalancers=$1
VIP=$2
for instance in $(echo $loadbalancers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"|grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip assign-vip.service assign-vip.sh configure-assign-vip.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x configure-assign-vip.sh $VIP"
done

