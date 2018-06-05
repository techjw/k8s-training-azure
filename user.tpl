- user: {{user}}
  nodes:
    master:
      name: "kube-{{user}}-master-1"
      fqdn: "{{master_fqdn}}"
      ip: "{{master_pubip}}"
      internalip: "{{master_ip}}"
    ingress:
      name: "kube-{{user}}-ingress-1"
      ip: "{{ingress_pubip}}"
      internalip: "{{ingress_ip}}"
    worker1:
      name: "kube-{{user}}-worker-1"
      ip: "{{worker1_pubip}}"
      internalip: "{{worker1_ip}}"
    worker2:
      name: "kube-{{user}}-worker-2"
      ip: "{{worker2_pubip}}"
      internalip: "{{worker2_ip}}"
