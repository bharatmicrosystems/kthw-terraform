loadbalancer=$1
ZONE=`gcloud compute instances list | grep ${loadbalancer} | awk '{ print $2 }'`
gcloud compute scp --zone=$ZONE --internal-ip configure-nginx.sh $loadbalancer:~/
gcloud compute ssh --zone=$ZONE --internal-ip $loadbalancer -- "cd ~/ && sh -x configure-nginx.sh" 
