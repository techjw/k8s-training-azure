resource "azurerm_public_ip" "k8singress" {
  name                         = "${var.project}-ingress-1-pubip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.kubernetes.name}"
  public_ip_address_allocation = "static"
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
    kube_component = "ingress"
  }
}

resource "azurerm_network_interface" "k8singress" {
  name                      = "${var.project}-ingress-1-nic"
  location                  = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name       = "${azurerm_resource_group.kubernetes.name}"
  ip_configuration {
    name                          = "${var.project}-ingress-1-ip"
    subnet_id                     = "${azurerm_subnet.kubernetes.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.k8singress.id}"
  }
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
    kube_component = "ingress"
  }
}

resource "azurerm_virtual_machine" "k8singress" {
  name                  = "${var.project}-ingress-1"
  location              = "${azurerm_resource_group.kubernetes.location}"
  resource_group_name   = "${azurerm_resource_group.kubernetes.name}"
  network_interface_ids = ["${azurerm_network_interface.k8singress.id}"]
  vm_size               = "${var.ingress_vm_size}"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.project}-ingress-1-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.project}-ingress-1"
    admin_username = "ubuntu"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path      = "/home/ubuntu/.ssh/authorized_keys"
      key_data  = "${file("${var.ssh_key}")}"
    }]
  }
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
    kube_component = "ingress"
  }
}
