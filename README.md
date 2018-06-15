DevOps Infrastructure Demo
===========================

This repository houses the demo code for Modus Create's
DevOps NYC talk titled Multi-Cloud Deployment with GitHub and Terraform.

To run the demo end to end, you will need:

* [AWS Account](https://aws.amazon.com/)
* [Packer](https://www.packer.io/)
* [Terraform](https://www.terraform.io/)


You will also need to set a few environment variables. The method of doing so will vary from platform to platform. 

```
AWS_PROFILE
AWS_DEFAULT_PROFILE
AWS_DEFAULT_REGION
PACKER_AWS_VPC_ID
PACKER_AWS_SUBNET_ID
```

A [sample file](env.sh.sample) is provided as a template to customize:

```
cp env.sh.sample env.sh
vim env.sh
. env.sh
```

The AWS profile IAM user should have administrative privileges in the account you are using.

Terraform
---------

This assumes that you already have a Route 53 domain in your AWS account created.
You need to either edit variables.tf to match your domain or specify the domain as a command line `var` parameter.

    cd terraform
    terraform get
    terraform plan -out tf.plan -var 'domain=example.net'
    terraform apply tf.plan
    # check to see if everything worked
    terraform destroy -var 'domain=example.net'

