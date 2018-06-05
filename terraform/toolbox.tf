resource "azurerm_public_ip" "toolbox" {
  name                         = "${var.project}-toolbox-pubip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${azurerm_resource_group.toolbox.name}"
  domain_name_label            = "${var.project}-${var.environment}-toolbox"
  public_ip_address_allocation = "static"
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_network_interface" "toolbox" {
  name                      = "${var.project}-toolbox-nic"
  location                  = "${azurerm_resource_group.toolbox.location}"
  resource_group_name       = "${azurerm_resource_group.toolbox.name}"
  network_security_group_id = "${azurerm_network_security_group.toolbox.id}"
  ip_configuration {
    name                          = "${var.project}-toolbox-ip"
    subnet_id                     = "${azurerm_subnet.toolbox.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.toolbox.id}"
  }
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_virtual_machine" "toolbox" {
  name                  = "${var.project}-toolbox"
  location              = "${azurerm_resource_group.toolbox.location}"
  resource_group_name   = "${azurerm_resource_group.toolbox.name}"
  network_interface_ids = ["${azurerm_network_interface.toolbox.id}"]
  vm_size               = "${var.toolbox_vm_size}"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "ubuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.project}-toolbox-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.project}-toolbox"
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
  }

  connection {
    type        = "ssh"
    private_key = "${file("${path.module}/../ssh/cluster.pem")}"
    user        = "ubuntu"
    host        = "${azurerm_public_ip.toolbox.ip_address}"
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "${path.module}/../ssh/cluster.pem"
    destination = "/home/ubuntu/kismatic.pem"
  }

  provisioner "file" {
    source = "${path.module}/user-data/kismatic-ansible.yaml"
    destination = "/home/ubuntu/kismatic-ansible.yaml"
  }

  provisioner "file" {
    source = "${path.module}/user-data/kismatic-cluster.yaml.j2"
    destination = "/home/ubuntu/kismatic-cluster.yaml.j2"
  }

  provisioner "file" {
    source = "${path.module}/user-data/prep-users.sh"
    destination = "/home/ubuntu/prep-users.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y -q",
      "sudo apt-get install -y -q ansible"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 kismatic.pem kismatic-ansible.yaml kismatic-cluster.yaml.j2",
      "chown ubuntu:ubuntu kismatic.pem kismatic-ansible.yaml kismatic-cluster.yaml.j2 prep-users.sh",
      "chmod 700 prep-users.sh"
    ]
  }
}

data "azurerm_public_ip" "toolbox" {
  name                = "${azurerm_public_ip.toolbox.name}"
  resource_group_name = "${azurerm_virtual_machine.toolbox.resource_group_name}"
  depends_on          = ["azurerm_virtual_machine.toolbox"]
}
