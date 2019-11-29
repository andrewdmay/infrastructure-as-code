# AWS Infrastructure as Code workshop

This is a workshop being presented at conferences.

## Presentations

[Introduction to AWS and Infrastructure as Code](presentations/Intro_to_AWS_and_Infrastructure_as_Code_Ohio_LinuxFest.pdf) - Ohio LinuxFest 2019 professional training

----

## Branches:

There are multiple branches for the Infrastructure as Code workshop that contain templates for creating a simple Auto Scaling Group and Load Balancer in various states of completion.

* `iac-start`: Template with parameters and outline
* `iac-iam`: IAM Role/Profile
* `iac-sg`: IAM, Security Groups
* `iac-alb`: IAM, Security Groups and ALB/Target Group/Listener
* `iac-solutions`: Complete template

----

## Pre-requisites

Clone the infrastructure as code repository: https://github.com/andrewdmay/infrastructure-as-code

Familiarity with the following will be helpful:
* Using the command line
* Cloud computing fundementals (virtual machines, load balancers, networking concepts)
* Basic Linux knowledge - the session can be completed using Windows/MacOS/Linux, but the servers created will run Linux.

AWS Accounts will be provided for the labs.

## Software:

### Required:

* Git client: https://git-scm.com/downloads
* Text Editor - ideally something that has support for the cfn-lint plugin - see [Editor Plugins](https://github.com/aws-cloudformation/cfn-python-lint#editor-plugins)
  * Atom: https://atom.io/
  * Visual Studio Code: https://code.visualstudio.com/Download
* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html - I recommend installing using pip if you have Python 3 installed
* Terraform CLI: https://www.terraform.io/downloads.html - sample templates have been created using Terraform 0.12

### Optional:

* Python cfn-lint package - `pip install -U cfn-lint`
* Text editor plugins for CloudFormation and Terraform
