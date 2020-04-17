#!/bin/bash
internal=false
external=false
healthz=":80/"
while getopts ":i:e:l:h:" opt; do
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
    esac
done

if $internal && $lb; then
  echo 'Startup....'
else
  echo "Usage: $0 -l LOAD_BALANCERS -i INTERNAL_VIP_NAME [-e EXTERNAL_VIP_NAME -h HEALTHZ_PORT_URI]"
  exit 1
fi
for action in stop stop stop; do
  if $internal; then
    #Get the VIPS
    INTERNAL_IP=`gcloud compute addresses list --filter="name=$internal_vip"| grep $internal_vip | awk '{ print $2 }'`
    INTERNAL_IP_STATUS=`gcloud compute addresses list --filter="name=$internal_vip"| grep $internal_vip | awk '{ print $NF }'`
    while [[ $INTERNAL_IP_STATUS != "IN_USE" ]]; do
      INTERNAL_IP_STATUS=`gcloud compute addresses list --filter="name=$internal_vip"| grep $internal_vip | awk '{ print $NF }'`
      echo "Waiting for the IP $INTERNAL_IP to be alloted to an instance"
      echo "Sleeping for 10 secs..."
      sleep 10
    done

    INTERNAL_INSTANCE_REGION=$(gcloud compute addresses list --filter="name=${internal_vip}"|grep ${internal_vip}|awk '{print $(NF-2)}')
    INTERNAL_INSTANCE_NAME=$(gcloud compute addresses describe ${internal_vip} --region=${INTERNAL_INSTANCE_REGION} --format='get(users[0])'|awk -F'/' '{print $NF}')
    INTERNAL_INSTANCE_ZONE=$(gcloud compute instances list --filter="name=${INTERNAL_INSTANCE_NAME}"|grep ${INTERNAL_INSTANCE_NAME}|awk '{print $2}')
    INTERNAL_INSTANCE_STATUS=$(gcloud compute instances describe --zone=${INTERNAL_INSTANCE_ZONE} $INTERNAL_INSTANCE_NAME --format='get(status)')
    echo "$INTERNAL_IP has been allocated to $INTERNAL_INSTANCE_NAME at $(date)"
    echo "Running some tests now..."
    status=$(curl -s -o /dev/null -w '%{http_code}' http://$INTERNAL_IP$healthz)
    echo "$(date): internal status: $status"
  fi
  echo "Sleeping for 10 secs..."
  sleep 10
  if $external; then
    EXTERNAL_IP=`gcloud compute addresses list --filter="name=$external_vip"| grep $external_vip | awk '{ print $2 }'`
    EXTERNAL_IP_STATUS=`gcloud compute addresses list --filter="name=$external_vip"| grep $external_vip | awk '{ print $NF }'`
    while [[ $EXTERNAL_IP_STATUS != "IN_USE" ]]; do
      EXTERNAL_IP_STATUS=`gcloud compute addresses list --filter="name=$external_vip"| grep $external_vip | awk '{ print $NF }'`
      echo "Waiting for the IP $EXTERNAL_IP to be alloted to an instance"
      echo "Sleeping for 10 secs..."
      sleep 10
    done

    EXTERNAL_INSTANCE_REGION=$(gcloud compute addresses list --filter="name=${external_vip}"|grep ${external_vip}|awk '{print $(NF-1)}')
    EXTERNAL_INSTANCE_NAME=$(gcloud compute addresses describe ${external_vip} --region=${EXTERNAL_INSTANCE_REGION} --format='get(users[0])'|awk -F'/' '{print $NF}')
    EXTERNAL_INSTANCE_ZONE=$(gcloud compute instances list --filter="name=${EXTERNAL_INSTANCE_NAME}"|grep ${EXTERNAL_INSTANCE_NAME}|awk '{print $2}')
    EXTERNAL_INSTANCE_STATUS=$(gcloud compute instances describe --zone=${EXTERNAL_INSTANCE_ZONE} $EXTERNAL_INSTANCE_NAME --format='get(status)')
    echo "$EXTERNAL_IP has been allocated to $EXTERNAL_INSTANCE_NAME at $(date)"
    echo "Running some tests now..."
    status=$(curl -s -o /dev/null -w '%{http_code}' http://$EXTERNAL_IP$healthz)
    echo "$(date): external status: $status"
  fi

  #Now stop the allocated instance
  echo "Taking $action action on instance $INTERNAL_INSTANCE_NAME at $(date)"
  gcloud compute instances $action -q --zone $INTERNAL_INSTANCE_ZONE $INTERNAL_INSTANCE_NAME
  echo "Sleeping for 1 minute for takeover before starting back $INTERNAL_INSTANCE_NAME"
  sleep 60
  if [[ $action == "stop" ]]; then
    echo "Taking start action on instance $INTERNAL_INSTANCE_NAME at $(date)"
    gcloud compute instances start --zone $INTERNAL_INSTANCE_ZONE $INTERNAL_INSTANCE_NAME
  fi
# INTERNAL_INSTANCE_STATUS=$(gcloud compute instances describe --zone=${INTERNAL_INSTANCE_ZONE} $INTERNAL_INSTANCE_NAME --format='get(status)')
# while [[ $INTERNAL_INSTANCE_STATUS == "STOPPING" ]]
# do
#    INTERNAL_INSTANCE_STATUS=$(gcloud compute instances describe --zone=${INTERNAL_INSTANCE_ZONE} $INTERNAL_INSTANCE_NAME --format='get(status)')
#    echo "Waiting for the instance $INTERNAL_INSTANCE to TERMINATE, current status $INTERNAL_INSTANCE_STATUS"
#    echo "Sleeping for 10 secs..."
#    sleep 10
#  done
done
