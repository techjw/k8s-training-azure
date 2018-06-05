#!/usr/bin/env bash
KETVERSION=${1:-"1.11.0"}

if [ "$USER" != "root" ]; then
  echo "Must run as root or with sudo."
  exit 1
fi

if [ ! -f trainees.yaml ]; then
  echo "ERROR: No trainees.yaml found. Unable to create users."
  exit 2
fi

echo -n "Fetching Kismatic Enterprise Toolkit v${KETVERSION}... "
tarball=kismatic-v${KETVERSION}-`uname|tr 'A-Z' 'a-z'`-amd64.tar.gz
curl -o kismatic.tar.gz -Ls https://github.com/apprenda/kismatic/releases/download/v${KETVERSION}/${tarball}
rc=$?
if [ $rc -eq 0 ]; then echo "Complete!"; else echo "Error downloading (rc=${rc})!"; exit 1; fi

echo "Creating group: training"
groupadd training 2>&1|grep -v invalidate # squelch nscd cache invalidation messages
USERS=$(grep '^-\ user:' trainees.yaml |awk '{print $3}')
for u in $USERS; do
  echo "Setting up user: ${u}"
  useradd -s /bin/bash -g training -m ${u} 2>&1|grep -v invalidate
  cp -p kismatic.pem /home/${u}
  mkdir /home/${u}/.ssh
  cp -p /home/ubuntu/.ssh/authorized_keys /home/${u}/.ssh/
  tar -C /home/${u} -zxf  kismatic.tar.gz
  chown -R ${u}:training /home/${u}
done

ansible-playbook kismatic-ansible.yaml -e @trainees.yaml
