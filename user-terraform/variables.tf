variable "master_vm_size"   { default = "Standard_B2ms" }
variable "worker_vm_size"   { default = "Standard_B2ms" }
variable "ingress_vm_size"  { default = "Standard_B2ms" }
variable "worker_count"     { default = 2 }

variable "azure_region"  { default = "East US" }
variable "vnet_cidr"    { default = "10.2.0.0/26" }
variable "local_cidr"   { default = "127.0.0.1/32" }
variable "toolbox_cidr" { default = "54.54.54.54/32" }
variable "ssh_key"      { default = "../ssh/cluster.pem.pub" }

variable "environment"  { default = "training" }
variable "project"      { default = "kube" }

variable "tenant_id"        { default = "your_tenant_id" }
variable "subscription_id"  { default = "your_subscription_id" }
variable "client_id"        { default = "your_client_id" }
variable "client_secret"    { default = "your_client_secret" }
