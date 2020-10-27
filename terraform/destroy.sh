#!/bin/bash
. ~/.bash_profile
terraform destroy -target=k8s_eip_assoc \
	-target=k8s-worker \
	-target=k8s-master \
	-target=worker-key \
	-target=master-key \
	-target=vpc_association \
	-target=vpc_internet_access \
	-target=vpc_master_rt \
	-target=subnet_2 \
	-target=subnet_1 \
	-target=azs \
	-target=igw \
	-target=vpc_master \
	-target=k9s-core-sg \
	-target=lb-sg 
