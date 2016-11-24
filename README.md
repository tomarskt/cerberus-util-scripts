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
Internally at Nike we do not use the image straight from canonical. Rather we create our own base ami that configures things like New Relic and Splunk and extra packages for security. We use that Base AMI to apply our custom Puppet Modules on top off.

For this project we distilled the essence of what you need for our Cerberus Puppet modules into these packer scripts.
You could fork this project and customize or build on top of the image from canonical and create your own base ami to use with these scripts.

### Bake the AMIs
To create the images for the various Cerberus components please run the following commands from the root of this project.
You will need the following params for each image.

Parameter          | Notes
-------------------|-------
source_ami         | The base AMI to use, currently it must be Unbuntu 14.04 based, if you dont have one you can use the base ami for [Ubuntu 14.04 LTS us-west-2 hvm:ebs-ssd base image supplied by caconical](https://cloud-images.ubuntu.com/locator/ec2/)
vpc_id             | The id of the VPC in which you will build your ami in. If you don't have a VPC you can run the wizard and create a vpc with a single public subnet.
subnet_id          | The subnet_id in which you will deploy the instance for packer to ssh into and build your AMI.
cerberus_component | The component to bake and AMI for: consul | vault | gateway | cms

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

CMS, requires one additional parameter.

If your using a self signed cert, you will need to modify https://github.com/Nike-Inc/cerberus-util-scripts/blob/master/bash_scripts/setup-oracle-java8.sh to add your CA to the trust store.

Parameter | Notes
----------|-------
cms_jar   | This is the release of CMS that you wish to use,  https://github.com/Nike-Inc/cerberus-management-service/releases/

    packer build \
    -var 'source_ami=ami-34913254' \
    -var 'vpc_id=vpc-6e768f09' \
    -var 'subnet_id=subnet-282d4670' \
    -var 'cms_jar_url=https://github.com/Nike-Inc/cerberus-management-service/releases/download/v0.6.0/cms.jar' \
    cms-packer.json
