variable "toolbox_vm_size"   { default = "Standard_B1s" }

variable "azure_region"  { default = "East US" }
variable "vnet_cidr"    { default = "10.1.0.0/28" }
variable "local_cidr"   { default = "127.0.0.1/32" }
variable "ssh_key"      { default = "../ssh/cluster.pem.pub" }

variable "environment"  { default = "training" }
variable "project"      { default = "k8s" }

variable "tenant_id"        { default = "your_tenant_id" }
variable "subscription_id"  { default = "your_subscription_id" }
variable "client_id"        { default = "your_client_id" }
variable "client_secret"    { default = "your_client_secret" }
