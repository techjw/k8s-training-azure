## Kubernetes on Azure for Training Classes
The focus of this code is to deploy multiple, identical Azure environments for installing basic Kubernetes clusters for classroom training.
Upon successful completion, the following instances will have been provisioned per user:

* 1 k8s master node
* 2 k8s worker nodes
* 1 k8s ingress controller node

Additionally, a single toolbox environment/instance will have been created for centralized execution of Kismatic installs

All instances are configured with public IPs, however firewall rules will only allow SSH, kubeapi, and HTTPS access from the CIDR blocks (`local_cidr`, `toolbox_cidr`) defined in `terraform/terraform.tfvars`, or the default value as set in [variables.tf](terraform/variables.tf) if no custom CIDRs are provided. Due to Azure's lack of an AWS-like split-horizon DNS, each worker and ingress public IP is also granted access to the kubeapi port.

Additionally, the following support infrastructure will be provisioned for each environment (toolbox and users):

* Custom Resource Group with a single virtual network, subnet and routing table
* Network security groups for allowing SSH, kubeapi, HTTPS, and internal network traffic

Since the environments generated are intended to be for simple and easy training environments, only a single SSH keypair is generated and intended to be shared with all trainees.

### Prerequisites
* Microsoft Azure account (https://azure.microsoft.com/en-us/free/)
* Azure CLI 2.0 (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* Terraform v0.11+ (https://www.terraform.io/downloads.html)

### Prepare Service Account

* To avoid having to login to the CLI constantly, create an Azure AD Service Account to configure for use with Terraform.
~~~
az login
az ad sp create-for-rbac --name kubernetes-training
~~~
  * Save the generated output, you will need the following:
      * `appID` will be used for `client_id`
      * `password` will be the `client_secret`
  * You should also get the tenant and subscription ID values from the output of `az account show`
      * `id` will be the `subscription_id`
      * `tenantId` will be `tenant_id` (obviously)

### Provision and Build a cluster

* Create a new `terraform\terraform.tfvars` file, and specify any overrides, especially:
    * `tenant_id`, `subscription_id`, `client_id`, and `client_secret`
    * `azure_region`
    * `local_cidr`
        * Run `curl ifconfig.co` from your local workstation and use that ip.address/32 for `local_cidr`
    * `toolbox_vm_size`
        * For testing, leave it as `Standard_B1s`, but during live builds you may want a larger instance to handle concurrent KET installs

* Prepare common keys, login to Azure and initialize the toolbox instance
~~~
make create-keypair
make prepare-toolbox
make create-toolbox
~~~

* Create a [user-terraform\terraform.tfvars](user-terraform\terraform.tfvars) file:
    * Use the same `tenant_id`, `subscription_id`, `client_id`, and `client_secret` values
    * Insert the toolbox instance's public IP in `toolbox_cidr` (e.g. 54.55.56.57/32)
    * Run `curl ifconfig.co` from your local workstation and use the ip.address/32 for `local_cidr`
    * Choose the same region as the toolbox
    * *Note*: you can speed up the user runs by pre-initializing terraform (`cd user-terraform && terraform init`)
    * *VM Size*: The current default `Standard_B2s` has been tested as the smallest size for consistently successful KET cluster installs (avoiding potential issues with starting up all components before timing out and such)

* Generate the user terraform directories and create the user instances:
    * You may also modify the [Makefile](Makefile) with the users if you don't want to type them out everytime
~~~
make prepare-users USERS="user1 user2 ... userN"
make create-users USERS="user1 user2 ... userN"
~~~

* Once the deployments complete, review the `generated/trainees.yaml` and upload it to the toolbox:
~~~
scp -i ssh/cluster.pem generated/trainees.yaml ubuntu@toolbox-public.dns.or.ip:~/
~~~

* Login to the toolbox instance, then generate the user setups:
~~~
ssh -i ssh/cluster.pem ubuntu@toolbox-public.dns.or.ip
sudo ./prep-users.sh
~~~
  *  `prep-users.sh` performs the following sequence of actions:
      * Download Kismatic (v1.11.0 unless passed a different version)
      * Create the group `training`
      * Generate all users, with home directories
      * Unpacks Kismatic and copies the RSA pem to each users' home
      * Sets up each user with authorized_keys (same key as ubuntu user)
      * Generates a customized `kismatic-cluster.yaml` in each users' home, filled in with their instance names and IPs

* At this point, users should be able to login to their user on the toolbox and execute standard KET workflows:
    * `./kismatic install validate`
    * `./kismatic install apply`

* When finished with the training environment, you may destroy all the resources that were provisioned. To do so, run the following:
~~~
make destroy-users USERS="user1 user2 ... userN"
make destroy-toolbox
make cleanup
az ad sp delete --id <kubernetes-training appID>
~~~
