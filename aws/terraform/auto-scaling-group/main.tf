# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
}

################################################################################
# Variables
################################################################################

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "max_size" {
  description = "Maxium size of AutoScaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum and inital size of AutoScaling Group"
  type        = number
  default     = 2
}

################################################################################
# Retrieve VPC/Subnet Ids and AMI
################################################################################

# Retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

# Retrieve the Subnet Ids for the default VPC
data "aws_subnet_ids" "subnet_ids" {
  vpc_id = data.aws_vpc.default.id
}

# Most Recent Amazon Linux AMI Id
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# Use a local for UserData
################################################################################

# Use UserData to:
#  - install nginx,
#  - start/enable it (systemctl)
#  - Download Website using AWS CLI from s3://workshop-iac-website/ to /usr/share/nginx/html/
#  - Substitude the EC2 instance id into index.html using sed (or tool of your choice) - ec2-metadata command returns details of instance
locals {
  instance-userdata = <<EOF
#!/bin/bash
yum update -y
# Install / start Nginx
# Download website
# Add instanceid to index.html
EOF
}

################################################################################
# IAM Resources
################################################################################

# The Role defines the assume role policy, but not an inline IAM policy
resource "aws_iam_role" "instance" {
  name_prefix = "WebServer-Instance-Role-"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Separate IAM Policy
resource "aws_iam_policy" "s3_access" {
  name_prefix = "Webserver-S3-Access-"
  description = "S3 Access for Instance Role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::workshop-iac-website",
        "arn:aws:s3:::workshop-iac-website/*"
      ]
    }
  ]
}
EOF
}

# Attach S3 Policy
resource "aws_iam_role_policy_attachment" "s3_access" {
  role = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Attach AWS SSM Session Manager Policy
resource "aws_iam_role_policy_attachment" "session_manager" {
  role = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "Webserver-Instance-Profile-"
  role = aws_iam_role.instance.name
}

################################################################################
# Security Groups
################################################################################

# Load Balancer Security Group allows HTTP access from anywhere
resource "aws_security_group" "load_balancer" {
  name_prefix = "Load-Balancer-HTTP-"
  description = "Load Balancer"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Terraform removes default Egress rule, so we have to add it back
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AutoScaling Group Security Group allows HTTP access from Load Balancer
resource "aws_security_group" "auto_scaling_group" {
  name_prefix = "Auto-Scaling-Group-HTTP-"
  description = "Auto Scaling Group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "From Load Balancer"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  # Terraform removes default Egress rule, so we have to add it back
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# Load Balancer
################################################################################

# Internet facing Load Balancer
resource "aws_lb" "alb" {
  name_prefix = "WS-LB-"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.load_balancer.id]
  subnets = data.aws_subnet_ids.subnet_ids.ids
}

# Default Target Group to which the EC2 instances in the ASG will be added
resource "aws_lb_target_group" "default" {
  name_prefix = "WS-TG-"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  deregistration_delay = 60
}

# HTTP Listener that directs all traffic to the default Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
}

################################################################################
# AutoScaling Group
################################################################################

# Template for instances in the AutoScaling Group
# Reference the Instance Profile created previously
# Use Ami Id retrieved by the data resource
# Use instance_type variable
# Use the Auto Scaling Group Security Group
# Add the Name tag to the generated instances so that it's displayed in the AWS Console

# resource "aws_launch_template" "webserver" {
#   user_data = "${base64encode(local.instance-userdata)}"
# }

# AutoScaling Group of Website EC2 instances
# This should reference the Launch Template using the latest version
# Desired Capacity / Min Size should use the min_size variable
# Max Size should use the max_size variable
# Instances should be registered with the Target Group

# resource "aws_autoscaling_group" "asg" {
#   vpc_zone_identifier = data.aws_subnet_ids.subnet_ids.ids
# }

output "load_balancer_domain_name" {
  value = aws_lb.alb.dns_name
}
