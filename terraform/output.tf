output "toolbox_public_ip" {
    value = "${data.azurerm_public_ip.toolbox.ip_address}"
}

output "toolbox_public_dns" {
    value = "${data.azurerm_public_ip.toolbox.fqdn}"
}
