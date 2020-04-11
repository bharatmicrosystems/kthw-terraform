masters=$1
master=$(echo $masters | cut -d ',' -f1)
ZONE=`gcloud compute instances list | grep ${master} | awk '{ print $2 }'`
gcloud compute scp --zone=$ZONE --internal-ip configure-networking.sh $master:~/
gcloud compute ssh --zone=$ZONE --internal-ip $master -- "cd ~/ && sh -x configure-networking.sh" 
