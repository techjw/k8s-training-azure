#!/usr/bin/env bash
ACTION=$1
shift
USERS=$@
MAINDIR=$PWD

function prepare_users {
  for u in $USERS; do
    echo "========== ${u} =========="
    mkdir -p generated/${u}
    cp -pr user-terraform generated/${u}/terraform
    cp -pr ssh generated/${u}/
    echo "project = \"kube-${u}\"" >> generated/${u}/terraform/terraform.tfvars
  done
}

function terra_create_users {
  cd ${MAINDIR}/generated
  echo "users:" > trainees.yaml

  for u in $USERS; do
    echo "========== ${u} =========="
    cd ${MAINDIR}/generated/${u}/terraform
    terraform init && terraform apply -auto-approve
    terraform output | sed -e "s/\ =\ /=/g" > ${MAINDIR}/generated/${u}.output

    cd ${MAINDIR}/generated
    source ${u}.output

    sed -e "s/{{user}}/${u}/g;
      s/{{master_fqdn}}/${master_pubdns}/g;
      s/{{master_ip}}/${master_ip}/g;
      s/{{master_pubip}}/${master_pubip}/g;
      s/{{worker1_ip}}/${worker1_ip}/g;
      s/{{worker1_pubip}}/${worker1_pubip}/g;
      s/{{worker2_ip}}/${worker2_ip}/g;
      s/{{worker2_pubip}}/${worker2_pubip}/g;
      s/{{ingress_ip}}/${ingress_ip}/g;
      s/{{ingress_pubip}}/${ingress_pubip}/g" \
      ${MAINDIR}/user.tpl >> trainees.yaml
  done
}

function terra_destroy_users {
  for u in $USERS; do
    echo "========== ${u} =========="
    cd ${MAINDIR}/generated/${u}/terraform
    terraform init && terraform destroy --force
    cd ${MAINDIR}/generated
    test -d ${u} && rm -r ${u}
  done
}

case $ACTION in
  'prepare') prepare_users ;;
  'create')  terra_create_users ;;
  'destroy') terra_destroy_users ;;
  *) echo "Unknown action: $ACTION"; exit 1 ;;
esac
