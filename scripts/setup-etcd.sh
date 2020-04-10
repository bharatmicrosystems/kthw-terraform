masters=$1
for instance in $(echo $masters | tr ',' ' '); do
  ZONE=`gcloud compute instances list | grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE bootstrap-etcd.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE ${instance} -- "cd ~/ && sh -x bootstrap-etcd.sh"
done
