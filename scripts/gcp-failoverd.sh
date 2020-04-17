#!/bin/bash
param=$1
internal_vip=$OCF_RESKEY_internal_vip
external_vip=$OCF_RESKEY_external_vip
healthz=$OCF_RESKEY_healthz
meta_data() {
  cat <<END
<?xml version="1.0"?>
<!DOCTYPE resource-agent SYSTEM "ra-api-1.dtd">
<resource-agent name="gcp-failoverd" version="0.1">
  <version>0.1</version>
  <longdesc lang="en"> floatip ocf resource agent for claiming a specified Floating IP via the GCP API</longdesc>
  <shortdesc lang="en">Assign Floating IP via GCP API</shortdesc>
  <parameters>
  <parameter name="internal_vip" unique="0" required="1">
    <longdesc lang="en">
    Name of the Internal VIP to be assigned to the resource
    </longdesc>
    <shortdesc lang="en">Internal VIP</shortdesc>
  </parameter>
  <parameter name="external_vip" unique="0" required="0">
    <longdesc lang="en">
    Name of the External VIP to be assigned to the resource
    </longdesc>
    <shortdesc lang="en">External VIP</shortdesc>
  </parameter>
  <parameter name="healthz" unique="0" required="0">
    <longdesc lang="en">
    The Health check endpoint in the format :port/url (default :80/)
    </longdesc>
    <shortdesc lang="en">Health check endpoint</shortdesc>
  </parameter>
</parameters>
  <actions>
    <action name="start"        timeout="6000" />
    <action name="stop"         timeout="20" />
    <action name="monitor"      timeout="20"
                                interval="10" depth="0" />
    <action name="meta-data"    timeout="5" />
  </actions>
</resource-agent>
END
}
if [[ "$external_vip" == "" ]] ; then
  external_params=""
else
  external_params=" -e $external_vip"
fi

if [[ "$healthz" == "" ]] ; then
  healthz=':80/'
fi
mkdir -p /var/log/gcp-failoverd
echo "$(date): Running agent for internal-vip: $internal_vip & external-vip: $external_vip with param: $param" >> /var/log/gcp-failoverd/startup.log
if [ "start" == "$param" ] ; then
  systemctl start nginx
  echo "$(date): Running agent start with params: -i ${internal_vip}${external_params} " >> /var/log/gcp-failoverd/startup.log
  /bin/sh /usr/bin/gcp-assign-vip.sh -i ${internal_vip}${external_params} >> /var/log/gcp-failoverd/startup.log
  exit 0
elif [ "stop" == "$param" ] ; then
  systemctl stop nginx
  exit 0
elif [ "status" == "$param" ] ; then
  status=$(curl -s -o /dev/null -w '%{http_code}' http://localhost$healthz)
  if [ $status -eq 200 ]; then
    echo "NGINX Running"
    exit 0
  else
    echo "NGINX is Stopped"
    exit 7
  fi
elif [ "monitor" == "$param" ] ; then
  status=$(curl -s -o /dev/null -w '%{http_code}' http://localhost$healthz)
  if [ $status -eq 200 ]; then
    echo "NGINX Running"
    exit 0
  else
    echo "NGINX is Stopped"
    exit 7
  fi
elif [ "meta-data" == "$param" ] ; then
  meta_data
  exit 0
else
  echo "no such command $param"
  exit 1;
fi
