DevOps Infrastructure Demo
===========================

This repository houses demo code for Modus Create's DevOps talks and meetups.

Originally this was targeted towards the [DevOps Wall Street](http://devopsnyc.co) talk titled _Multi-Cloud Deployment with GitHub and Terraform_. See the branch [demo-20170303](https://github.com/ModusCreateOrg/devops-infra-demo/tree/demo-20170303) for the code demonstrated at that event.

See the branch [demo-20180619](https://github.com/ModusCreateOrg/devops-infra-demo/tree/demo-20180619) for the code for the demo for the [NYC DevOps talk _Applying the CIS Baseline using Ansible & Packer_](https://www.meetup.com/nycdevops/events/fmgjmnyxjbzb/).

Multi-Cloud Deployment with GitHub and Terraform Instructions
-------------------------------------------------------------

To run the demo end to end, you will need:

* [AWS Account](https://aws.amazon.com/)
* [Google Cloud Account](https://cloud.google.com/)
* [Packer](https://www.packer.io/) (tested with 1.0.3)
* [Terraform](https://www.terraform.io/) (tested with  v0.11.7)

You will also need to set a few environment variables. The method of doing so will vary from platform to platform.

```
AWS_PROFILE
AWS_DEFAULT_PROFILE
AWS_DEFAULT_REGION
GOOGLE_CLOUD_KEYFILE_JSON
GOOGLE_PROJECT
GOOGLE_REGION
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

You will need to create an application in the Google developer console, create a set of service-to-service JSON credentials, and enable the Google Cloud Storage API in the referenced Google developer application for the Google integration to work. If you don't care about that, alternately you may remove the `terraform/google.tf` file to get the demo to work without the Google part.

Terraform
---------

This assumes that you already have a Route 53 domain in your AWS account created.
You need to either edit variables.tf to match your domain, ami, and AWS zone or specify these values as command line `var` parameters.

    cd terraform
    terraform get
    # Example with values from our environment (replace with values from your environment)
    # terraform plan -var zone=us-east-2 -var ami=ami-08f730916e53de731 -var domain=moduscreate.com -out tf.plan
    terraform plan -out tf.plan -var 'domain=example.net'
    terraform apply tf.plan
    # check to see if everything worked - use the same variables here as above
    terraform destroy -var 'domain=example.net'

