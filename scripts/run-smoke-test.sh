masters=$1
etcds=$2
master=$(echo $masters | cut -d ',' -f1)
etcd=$(echo $etcds | cut -d ',' -f1)
ZONE=`gcloud compute instances list --filter="name=${master}"| grep ${master} | awk '{ print $2 }'`
gcloud compute scp --zone=$ZONE --internal-ip smoke-test.sh $master:~/
gcloud compute ssh --zone=$ZONE --internal-ip $master -- "cd ~/ && sh -x smoke-test.sh"
ZONE=`gcloud compute instances list --filter="name=${etcd}" | grep ${etcd} | awk '{ print $2 }'`
gcloud compute scp --zone=$ZONE --internal-ip smoke-test-etcd.sh $etcd:~/
gcloud compute ssh --zone=$ZONE --internal-ip $etcd -- "cd ~/ && sh -x smoke-test-etcd.sh"
ZONE=`gcloud compute instances list --filter="name=${master}"| grep ${master} | awk '{ print $2 }'`
gcloud compute scp --zone=$ZONE --internal-ip smoke-test-cleanup.sh $master:~/
gcloud compute ssh --zone=$ZONE --internal-ip $master -- "cd ~/ && sh -x smoke-test-cleanup.sh"
