workers=$1
for instance in $(echo $workers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip bootstrap-worker.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x bootstrap-worker.sh"
done
