loadbalancer=$1
ZONE=`gcloud compute instances list | grep ${loadbalancer} | awk '{ print $2 }'`
gcloud compute scp --zone=$ZONE configure-nginx.sh $loadbalancer:~/
gcloud compute ssh --zone=$ZONE $loadbalancer -- "cd ~/ && sh -x configure-nginx.sh" 
