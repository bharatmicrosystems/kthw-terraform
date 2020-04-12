masters=$1
workers=$2
#Worker
for instance in $(echo $workers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
#Master
for instance in $(echo $masters | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"| grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
