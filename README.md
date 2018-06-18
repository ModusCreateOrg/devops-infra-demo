DevOps Infrastructure Demo
===========================

This repository houses demo code for Modus Create's DevOps talks and meetups.

Originally this was targeted towards the DevOps NYC talk titled _Multi-Cloud Deployment with GitHub and Terraform_.

See the branch [demo-20180619](https://github.com/ModusCreateOrg/devops-infra-demo/tree/demo-20180619) for the code for the demo for the NYC DevOps talk _Applying the CIS Baseline using Ansible & Packer_.

Multi-Cloud Deployment with GitHub and Terraform Instructions
-------------------------------------------------------------


To run the demo end to end, you will need:

* [AWS Account](https://aws.amazon.com/)
* [Google Cloud Account](https://cloud.google.com/)
* [Packer](https://www.packer.io/)
* [Terraform](https://www.terraform.io/)

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
