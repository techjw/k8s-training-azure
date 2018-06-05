output "master_ip" {
    value = "${azurerm_network_interface.k8smaster.private_ip_address}"
}
output "master_pubip" {
    value = "${azurerm_public_ip.k8smaster.ip_address}"
}
output "master_pubdns" {
    value = "${data.azurerm_public_ip.k8smaster.fqdn}"
}

output "worker1_ip" {
  value = "${azurerm_network_interface.k8sworker.*.private_ip_address[0]}"
}
output "worker1_pubip" {
  value = "${azurerm_public_ip.k8sworker.*.ip_address[0]}"
}
output "worker2_ip" {
  value = "${azurerm_network_interface.k8sworker.*.private_ip_address[1]}"
}
output "worker2_pubip" {
  value = "${azurerm_public_ip.k8sworker.*.ip_address[1]}"
}

output "ingress_ip" {
    value = "${azurerm_network_interface.k8singress.private_ip_address}"
}
output "ingress_pubip" {
    value = "${azurerm_public_ip.k8singress.ip_address}"
}
