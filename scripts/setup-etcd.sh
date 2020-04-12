etcds=$1
loadbalancer=$2
LB_INTERNAL_ADDRESS=`gcloud compute addresses list --filter="name=$loadbalancer"| grep $loadbalancer | awk '{ print $2 }'`
for instance in $(echo $etcds | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip bootstrap-etcd.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x bootstrap-etcd.sh $etcds $LB_INTERNAL_ADDRESS"
done
