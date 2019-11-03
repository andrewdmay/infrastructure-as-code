# AWS Infrastructure as Code workshop

This is a workshop being presented at conferences.

## Presentations

[Introduction to AWS and Infrastructure as Code](presentations/Intro to AWS and Infrastructure as Code - Ohio LinuxFest.pdf) - Ohio LinuxFest 2019 professional training

----

## Branches:

There are multiple branches for the Infrastructure as Code workshop that contain templates for creating a simple Auto Scaling Group and Load Balancer in various states of completion.

* `iac-start`: Template with parameters and outline
* `iac-iam`: IAM Role/Profile
* `iac-sg`: IAM, Security Groups
* `iac-alb`: IAM, Security Groups and ALB/Target Group/Listener
* `iac-solutions`: Complete template

## Software:

Although the created EC2 instances will be running Linux and you are expected to have some Linux experience, the lab can be completed using Windows/MacOS.

AWS Accounts will be provided for the labs, but you may use your own - you might incur some costs depending upon whether your account is less than 12 months old (see [free tier](https://aws.amazon.com/free/free-tier/)) and exactly what resources are created.

## Required:

* Git
* SSH Client
* Text Editor - ideally something that has support for the cfn-lint plugin - see [Editor Plugins](https://github.com/aws-cloudformation/cfn-python-lint#editor-plugins)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) - I recommend installing using pip if you have Python 3 installed
* [Terraform CLI](https://www.terraform.io/downloads.html) - sample templates have been created using Terraform 0.12

## Optional:

* Python cfn-lint package - `pip install -U cfn-lint`
* Text editor plugins for CloudFormation and Terraform

