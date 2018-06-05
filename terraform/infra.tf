provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
}

resource "azurerm_resource_group" "toolbox" {
  name     = "${var.project}-${var.environment}-rg"
  location = "${var.azure_region}"
  tags {
      environment = "${var.environment}"
      project = "${var.project}"
  }
}

resource "azurerm_virtual_network" "toolbox" {
  name                = "${var.project}-${var.environment}-vnet"
  address_space       = ["${var.vnet_cidr}"]
  location            = "${azurerm_resource_group.toolbox.location}"
  resource_group_name = "${azurerm_resource_group.toolbox.name}"
  tags {
    environment = "${var.environment}"
    project = "${var.project}"
  }
}

resource "azurerm_network_security_group" "toolbox" {
    name                = "${var.project}-${var.environment}-nsg"
    location            = "${var.azure_region}"
    resource_group_name = "${azurerm_resource_group.toolbox.name}"
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["${var.vnet_cidr}", "${var.local_cidr}"]
        destination_address_prefix = "*"
    }
    tags {
      environment = "${var.environment}"
      project = "${var.project}"
    }
}

resource "azurerm_route_table" "toolbox" {
  name                = "${var.project}-${var.environment}-rt"
  location            = "${azurerm_resource_group.toolbox.location}"
  resource_group_name = "${azurerm_resource_group.toolbox.name}"
}

resource "azurerm_subnet" "toolbox" {
  name                      = "${var.project}-${var.environment}-subnet"
  resource_group_name       = "${azurerm_resource_group.toolbox.name}"
  virtual_network_name      = "${azurerm_virtual_network.toolbox.name}"
  address_prefix            = "${var.vnet_cidr}"
  route_table_id            = "${azurerm_route_table.toolbox.id}"
  network_security_group_id = "${azurerm_network_security_group.toolbox.id}"
}
