# Cerberus Utility Scripts

This repository contains the scripts needed to bake to various AMIs that compose a Cerberus environment.

## AMIs

To build the Cerberus AMIs we need to set the following environmental variables

- AWS_ACCESS_KEY=[ACCESS KEY FOR IAM USER]
- AWS_SECRET_ACCESS_KEY=[SECRET ACCESS KEY FOR IAM USER]
- CERBERUS_BASE_AMI=[BASE AMI TO BUILD ON TOP OF]

For OSS testing I used the [Ubuntu 16.04 LTS us-west-2 hvm:ebs-ssd base image](https://cloud-images.ubuntu.com/locator/ec2/)

### Cerberus Management Service

### Gateway

### Vault

### Consul

    packer build \
    -var 'source_ami=${CERBERUS_BASE_AMI}' \
    consul/packer/packer.json 