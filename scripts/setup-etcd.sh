etcds=$1
loadbalancer=$2
for instance in $(echo $etcds | tr ',' ' '); do
  ZONE=`gcloud compute instances list | grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip bootstrap-etcd.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x bootstrap-etcd.sh $etcds $loadbalancer"
done
