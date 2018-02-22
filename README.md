# Cerberus Utility Scripts

This repository contains the scripts needed to bake the Cerberus Management Service AMI.

Creating the AMI is the first step in [creating a Cerberus environment](http://engineering.nike.com/cerberus/docs/administration-guide/creating-an-environment).

To learn more about Cerberus, please visit the [Cerberus website](http://engineering.nike.com/cerberus/).

## Requirements

Install [Packer](https://www.packer.io/docs/installation.html), a tool for creating machine images.

## AMIs

To build the Cerberus AMIs we need to set the following environmental variables

- AWS_ACCESS_KEY_ID=[AWS Access Key for user or role]
- AWS_SECRET_ACCESS_KEY=[AWS Secret Access Key for user or role]

If you are using temp credentials you'll need to modify **packer.json** and **cms-packer.json** to include the temp 
token. For example, modify the packer json files by adding the two lines highlighted below:

<pre>
{
  "variables": {
    "aws_access_key": "{{env `AWS_ACCESS_KEY_ID`}}",
    "aws_secret_key": "{{env `AWS_SECRET_ACCESS_KEY`}}",
    <b>"aws_session_token": "{{env `AWS_SESSION_TOKEN`}}",</b>
    "region": "us-west-2",
    "source_ami": null,
    "vpc_id": null,
    "subnet_id": null
  },
  "builders": [{
    "type": "amazon-ebs",
    "access_key": "{{user `aws_access_key`}}",
    "secret_key": "{{user `aws_secret_key`}}",
    <b>"token": "{{ user `aws_session_token`}}",</b>
    "vpc_id": "{{user `vpc_id`}}",
    "subnet_id": "{{user `subnet_id`}}",
...
</pre>

For OSS testing I used the [Ubuntu 14.04 LTS us-west-2 hvm:ebs-ssd base image](https://cloud-images.ubuntu.com/locator/ec2/)
Currently our Puppet modules and packer scripts are written for Ubuntu 14.04, we plan on migrating everything to 16.04.
Hopefully all that is needed to support 16.04 is porting the startup scripts from Upstart to systemd.

Also the packer in this project currently makes use of apt-get, if we port the bash to puppet completely we would
probably be able to support more distros

### NOTE
Internally at Nike we do not use the image straight from canonical. Rather we create our own base AMI that configures
things like New Relic and Splunk and extra packages for security. We use that Base AMI to apply our custom Puppet Modules on top off.

For this project we distilled the essence of what you need for our Cerberus Puppet modules into these packer scripts.
You could fork this project and customize or build on top of the image from canonical and create your own base AMI to
use with these scripts.

CMS logs to `/var/log/cms/`.

### Bake the AMI

To create the images for the various Cerberus components please run the following commands from the root of this project.
You will need the following params for each image.

Download the version of CMS you want and place it in `additional_files/`

Here is a [script we use in our build system](https://gist.github.com/anonymous/2d2155fdcfc2d92ce84db354dae736ee), it requires `wget`, `jq`, and a `Java 8 JRE`

You can optionally specify an env var `CMS_RELEASE_TARGET` and it will attempt to download that published version, if there is no version published matching `CMS_RELEASE_TARGET` it will attempt to checkout a branch or tag and compile it. 
If you do not specify `CMS_RELEASE_TARGET` it will download the latest release.

Parameter          | Notes
-------------------|-------
source_ami         | The base AMI to use, currently it must be Unbuntu 14.04 based, if you dont have one you can use the base AMI for [Ubuntu 14.04 LTS us-west-2 ami-8f78c2f7base image supplied by caconical](https://cloud-images.ubuntu.com/locator/ec2/)
vpc_id             | The id of the VPC in which you will build your AMI in. If you don't have a VPC you can run the wizard and create a vpc with a single public subnet.
subnet_id          | The subnet_id in which you will deploy the instance for packer to ssh into and build your AMI.

```bash
wget https://github.com/Nike-Inc/cerberus-management-service/releases/download/v3.10.0/cms.jar -O additional_files/cms.jar

packer build \
-var 'source_ami=ami-8f78c2f7' \
-var 'vpc_id=vpc-6e768f09' \
-var 'subnet_id=subnet-282d4670' \
-var 'ami_name=cms' \
-var 'ssh_username=ubuntu' \
cms-packer.json
```

## Troubleshooting

#### required variable not set: xxxx

Double check apostrophes from above -var commands were copied and pasted correctly (for example, copying code to
TextEdit on Mac will convert to smart quotes and cause this error).

#### Misc Error

AWS just fails sometimes, so if you see an error with no explanation try building a second time.
