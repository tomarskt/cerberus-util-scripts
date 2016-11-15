# Cerberus Utility Scripts

This repository contains the scripts needed to bake to various AMIs that compose a Cerberus environment.

## AMIs

To build the Cerberus AMIs we need to set the following environmental variables

- AWS_ACCESS_KEY=[AWS Access Key for user or role]
- AWS_SECRET_ACCESS_KEY=[AWS Secret Access Key for user or role]

if you are using temp credentials you can modify the packer files to have the temp token

For OSS testing I used the [Ubuntu 14.04 LTS us-west-2 hvm:ebs-ssd base image](https://cloud-images.ubuntu.com/locator/ec2/)

### Cerberus Management Service

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=cms' \
    cms/packer.json

### Gateway

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=gateway' \
    packer.json

### Vault

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=vault' \
    packer.json

### Consul

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=consul' \
    packer.json