masters=$1
workers=$2
etcds=$3
# Worker nodes
for instance in $(echo $workers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip ca.pem ${instance}-key.pem ${instance}.pem ${instance}:~/
done

#Master nodes
for instance in $(echo $masters | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem etcd-key.pem etcd.pem \
    service-account-key.pem service-account.pem ${instance}:~/
done

#ETCD Nodes
for instance in $(echo $etcds | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip ca.pem etcd-key.pem etcd.pem ${instance}:~/
done
