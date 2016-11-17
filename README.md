# Cerberus Utility Scripts

This repository contains the scripts needed to bake to various AMIs that compose a Cerberus environment.

## Requirements

Install [Packer](https://www.packer.io/docs/installation.html)

## AMIs

To build the Cerberus AMIs we need to set the following environmental variables

- AWS_ACCESS_KEY=[AWS Access Key for user or role]
- AWS_SECRET_ACCESS_KEY=[AWS Secret Access Key for user or role]

if you are using temp credentials you can modify the packer files to have the temp token

For OSS testing I used the [Ubuntu 14.04 LTS us-west-2 hvm:ebs-ssd base image](https://cloud-images.ubuntu.com/locator/ec2/)
Currently our Puppet modules and packer scripts are written for Ubuntu 14.04, we plan on migrating everything to 16.04.
Hopefully all that is needed to support 16.04 is porting the startup scripts from Upstart to systemd.

Also the packer in this project currently makes use of apt-get, if we port the bash to puppet completely we would probably be able to support more distros

### NOTE
Internally at Nike we do not use the image straight from canonical like this README suggests you can for getting started.

We create our own base ami that configures things like New Relic and Splunk and extra packages for security.
For this project we distilled the essence of what you need for our Cerberus Puppet modules into the packer scripts.

### Bake the AMIs
To create the images for the various Cerberus components please run the following commands from the root of this project.

### Consul

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=consul' \
    packer.json

### Vault

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=vault' \
    packer.json  

### Gateway

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cerberus_component=gateway' \
    packer.json

### Cerberus Management Service

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cms_jar_url=https://github.com/Nike-Inc/cerberus-management-service/releases/download/v1.0.0/cms.jar' \
    cms-packer.json
