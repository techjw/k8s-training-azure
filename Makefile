USERS="user1"

create-keypair:
	test -d ssh || mkdir ssh
	cd ssh && ssh-keygen -t rsa -f cluster.pem -N "" -C "k8s-training-key"
	chmod 600 ssh/cluster.pem

prepare-toolbox:
	cd terraform && terraform init && terraform plan

create-toolbox:
	cd terraform && terraform init && terraform apply

destroy-toolbox:
	cd terraform && terraform init && terraform destroy --force
	cd terraform && rm terraform.tfstate terraform.tfstate.backup

prepare-users:
	./terrausers.sh prepare $(USERS)

create-users:
	./terrausers.sh create $(USERS)

destroy-users:
	./terrausers.sh destroy $(USERS)

cleanup:
	test -d ssh && rm -r ssh/
	test -d generated && rm -r generated/
