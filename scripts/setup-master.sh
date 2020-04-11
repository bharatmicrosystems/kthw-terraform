masters=$1
loadbalancer=$2
ZONE=`gcloud compute instances list | grep $loadbalancer | awk '{ print $2 }'`
KUBERNETES_INTERNAL_ADDRESS=$(gcloud compute instances describe --zone=$ZONE $loadbalancer \
  --format 'value(networkInterfaces[0].networkIP)')
for instance in $(echo $masters | tr ',' ' '); do
  ZONE=`gcloud compute instances list | grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip bootstrap-master.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x bootstrap-master.sh $KUBERNETES_INTERNAL_ADDRESS"
done
