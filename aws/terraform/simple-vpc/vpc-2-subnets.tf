# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.100.0.0/16"

  tags = {
    Name = "Terraform Simple VPC"
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block        = "10.100.0.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-2a"

  tags = {
    Name = "Terraform Subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  cidr_block        = "10.100.1.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-2b"

  tags = {
    Name = "Terraform Subnet2"
  }
}
