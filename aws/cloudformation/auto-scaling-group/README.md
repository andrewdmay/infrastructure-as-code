# Auto Scaling Group of Web Servers

This CloudFormation Template creates an AutoScaling Group of EC2 instances running Nginx and hosting a (very) basic website.

The resources in the template are in roughly the order they need to be created due to dependencies, but CloudFormation will create resources in parallel where possible.

## Resources

* IAM:
  * IAM Role used for EC2 instances
    * Gives access to S3 bucket from which the website is downloaded
    * Uses managed policy for Session Manager which allows a shell to be opened without using SSH
  * Instance Profile for the IAM Role
* Security Groups:
  * Security Group for the Load Balancer allows port 80 to be accessed from anywhere
  * Security Group for the AutoScaling Group allows port 80 to be **only** accessed from the Load Balancer Security Group
* Load Balancing:
  * Application Load Balancer
  * Default Target Group to which EC2 instances will be automatically added with the AutoScaling Group
  * HTTP Listener which listens on port 80 and routes all traffic to the default Target Group
* AutoScaling:
  * Launch Template for the EC2 instances - UserData is used to install Nginx and download files from S3
  * AutoScaling Group that uses the Launch Template and adds instances to the Target Group of the ALB

## CloudFormation CLI commands

> Commands assume that this is either using the `default` profile or the `AWS_PROFILE` environment variable has been set. Otherwise add the `--profile` argument.

__Create stack:__
```
aws cloudformation create-stack --stack-name AutoScalingGroup --template-body file://asg.yml --parameters file://asgParameters.json --capabilities CAPABILITY_IAM
```

__Update stack:__
```
aws cloudformation update-stack --stack-name AutoScalingGroup --template-body file://asg.yml --parameters file://asgParameters.json --capabilities CAPABILITY_IAM
```

__Delete stack:__
```
aws cloudformation delete-stack --stack-name AutoScalingGroup
```

When making changes it can be quicker to create the stack with the portion of the template that is known to work and then update it with changes to the template. If the changes do not work they will rollback to the previous state. This is quicker than deleting the stack and recreating every time.

## Notes about this example

There are a number of limitations of this stack to make it simpler:

* In order to use the default VPC which only has public subnets, the ALB and the EC2 instances are created in the same subnets. This results in the EC2 instances having public IP addresses even though they are not accessible due to the security group.
  * Normally you would put the EC2 instances in a private subnet that would access the internet (where necessary) via a NAT gateway in a public subnet.
* We do not have a DNS alias for the Load Balancer
  * This would require a public Route 53 hosted zone to be configured in the account
* The ALB is using HTTP rather than HTTPS
  * Using a certificate would require a domain name and certificate, which would typically use a Route 53 hosted zone and AWS Certificate Manager
* There is no scaling on the AutoScaling Group
  * There are still benefits to using an ASG without scaling because it will automatically recreate terminated instances providing high availability
* We are not collecting logs from the EC2 instances (e.g. the Nginx access log)
  * Logs could be sent to CloudWatch logs using the CloudWatch agent
