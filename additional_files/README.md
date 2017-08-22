# Additional Files

Place files in this folder to be uploaded to the file system on the Cerberus
Management Service (CMS) AMI.

When the Packer JSON file for CMS (`cms-packer.json`) is executed, all files in
this directory will be uploaded to the `/tmp` directory on the newly baked CMS
AMI.  These files can then be used to apply additional customizations to the AMI
that make sense for your company (e.g. vendor specific metrics and/or monitoring).
