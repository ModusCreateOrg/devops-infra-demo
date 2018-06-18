DevOps Infrastructure Demo
===========================

This repository houses demo code for Modus Create's DevOps talks and meetups.

Originally this was targeted towards the DevOps NYC talk titled _Multi-Cloud Deployment with GitHub and Terraform_.

See the branch [demo-20180619](https://github.com/ModusCreateOrg/devops-infra-demo/tree/demo-20180619) for the code for the demo for the NYC DevOps talk _Applying the CIS Baseline using Ansible & Packer_.

Applying the CIS Benchmark using Ansible & Packer Instructions
--------------------------------------------------------------

To run the demo end to end, you will need:

* [AWS Account](https://aws.amazon.com/)
* [Packer](https://www.packer.io/)

Optionally, you can use Vagrant to test ansible playbooks locally and Jenkins to orchestrate creation of AMIs in conjunction with GitHub branches and pull requests.

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

The AWS profile IAM user should have full control of EC2 in the account you are using.

### Packer

Run `packer/bin/pack.sh` to initiate a Packer run. This will provision a machine on EC2, configure it using Ansible, and scan it using OpenSCAP. The results from the scan will end up in `packer/build`.

### Vagrant

In order to make developing the Ansible playbooks faster, a Vagrantfile is provided to provision a VM locally.

Install [Vagrant](https://www.vagrantup.com/). Change directory into `packer` and do a `vagrant up`. You can add or edit Ansible playbooks and support scripts then re-run the provisioning with `vagrant provision` to refine the remediations. This is more efficient that re-running packer and baking new AMIs for every change.

### Jenkins

A `Jenkinsfile` is provided that will make Jenkins execute a packer run on every commit. In order for Jenkins to do this, it needs to have AWS credentials set up, preferably through an IAM role, granting full control of EC2 resources in that account. Packer needs this in order to create AMIs, key pairs, etc. This could be pared down further through some careful logging and role work.
