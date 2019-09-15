variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = number
  default     = 3
}

variable "subnet_bits" {
  description = "Number of bits in addition to CIDR bits (e.g. if CIDR is /16, make this 8 for /24 subnets)"
  type        = number
  default     = 8
}

# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Terrform Parameterized VPC"
  }
}

# Retrieve information about availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create multiple subnets, based upon subnet_count variable
# CIDR block is determined based upon VPC CIDR, number of subnet bits and count index
# Availability zone round-robins the available AZs
resource "aws_subnet" "subnet" {
  count = var.subnet_count

  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_bits, count.index)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = format("Terrform Subnet %s", count.index)
  }
}
