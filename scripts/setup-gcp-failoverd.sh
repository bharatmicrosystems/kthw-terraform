#!/bin/bash
lb=false
cm=false
internal=false
external=false
healthz=":80/"
while getopts ":i:e:l:h:c:" opt; do
    case "$opt" in
    i)  internal_vip=$OPTARG
        internal=true
        ;;
    e)  external_vip=$OPTARG
        external=true
        ;;
    l)  loadbalancers=$OPTARG
        lb=true
        ;;
    h)  healthz=$OPTARG
        ;;
    c)  CLUSTER_NAME=$OPTARG
        cn=true
    esac
done

if $lb && $cn && $internal; then
  echo 'Startup....'
else
  echo "Usage: $0 -l LOAD_BALANCERS -c CLUSTER_NAME -i INTERNAL_VIP_NAME [-e EXTERNAL_VIP_NAME -h HEALTHZ_PORT_URI]" >&2
  exit 1
fi


priority=150
instance=$(echo $loadbalancers | tr ',' ' ' | awk {'print $1'})
PARAMS=''
if $internal; then
  PARAMS="$PARAMS internal_vip=${internal_vip}"
#  sed -i "s/#PARAMS/internal_vip=${internal_vip}/g" configure-gcp-failoverd-start.sh
#  sed -i "s/#internal=true/internal=true/g" gcp-assign-vip.sh
#else
#  sed -i "s/#internal=true/internal=false/g" gcp-assign-vip.sh
fi

if $external; then
    PARAMS="$PARAMS external_vip=${external_vip}"
#  sed -i "s/#external_vip/external_vip=${external_vip}/g" gcp-assign-vip.sh
#  sed -i "s/#external=true/external=true/g" gcp-assign-vip.sh
#else
#  sed -i "s/#external=true/external=false/g" gcp-assign-vip.sh
fi
sed -i "s/#PARAMS/${PARAMS} healthz=$healthz/g" configure-gcp-failoverd-start.sh
cp -a configure-gcp-failoverd-init.sh.template configure-gcp-failoverd-init.sh
cp -a configure-gcp-failoverd-bootstrap.sh.template configure-gcp-failoverd-bootstrap.sh
PASSWORD=`head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`
sed -i "s/#PASSWORD/$PASSWORD/g" configure-gcp-failoverd-init.sh
sed -i "s/#PASSWORD/$PASSWORD/g" configure-gcp-failoverd-bootstrap.sh
sed -i "s/#CLUSTER_NAME/$CLUSTER_NAME/g" configure-gcp-failoverd-bootstrap.sh
sed -i "s/#PRIMARY_IP/$instance/g" configure-gcp-failoverd-bootstrap.sh
priority=$(($priority - 10))
SECONDARY_IPS=''
for peer in $(echo $loadbalancers | tr ',' ' '); do
  if [[ $peer != $instance ]]; then
    SECONDARY_IPS=$SECONDARY_IPS" "$peer
  fi
done
sed -i "s/#SECONDARY_IPS/$SECONDARY_IPS/g" configure-gcp-failoverd-bootstrap.sh

for instance in $(echo $loadbalancers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"|grep ${instance} | awk '{ print $2 }'`
  gcloud compute scp --zone=$ZONE --internal-ip gcp-failoverd.sh gcp-assign-vip.sh configure-gcp-failoverd-init.sh configure-gcp-failoverd-bootstrap.sh configure-gcp-failoverd-start.sh ${instance}:~/
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x configure-gcp-failoverd-init.sh"
done

instance=$(echo $loadbalancers | tr ',' ' ' | awk {'print $1'})
ZONE=`gcloud compute instances list --filter="name=${instance}"|grep ${instance} | awk '{ print $2 }'`
gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x configure-gcp-failoverd-bootstrap.sh"

for instance in $(echo $loadbalancers | tr ',' ' '); do
  ZONE=`gcloud compute instances list --filter="name=${instance}"|grep ${instance} | awk '{ print $2 }'`
  gcloud compute ssh --zone=$ZONE --internal-ip ${instance} -- "cd ~/ && sh -x configure-gcp-failoverd-start.sh"
done

echo "Sleeping for 10 secs before firing test..."
sleep 10
sh -x smoke-test.sh -i $internal_vip -e $external_vip -l $loadbalancers -h $healthz
