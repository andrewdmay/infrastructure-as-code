# Auto Scaling Group of Web Servers

This Terraform template creates an AutoScaling Group of EC2 instances running Nginx and hosting a (very) basic website.

See the [CloudFormation](../../clouformation/auto-scaling-group/) version of this same infrastructure.

The resources in the template are in roughly the order they need to be created due to dependencies, but Terraform will create resources in parallel where possible.

## Terraform CLI commands

It is assumed that you are either using `default` AWS profile, or have the `AWS_PROFILE` environment variable set.

If you don't want to be prompted for the region, set the `AWS_REGION` environment variable.

__Initialize:__

The first time you apply the template you will need to call `terraform init` which will install providers (in this case the aws one) into the `.terraform` directory.

__Create or Update:__

```
terraform apply --auto-approve
```

When complete this will print the outputs, which in this case is just the Domain Name of the Load Balancer.

> The `--auto-approve` prevents it from prompting you to approve the changes

__Delete:__

```
terraform destroy --auto-approve
```

## Differences to CloudFormation

There are a few differences between the Terraform template and the CloudFormation template in terms of how resources are created, although they are mostly very similar but in a different syntax.

* Instead of having to supply the VPC Id and Subnet Ids, the template uses data resources to look up the default VPC and it's subnets
* Finding the AMI Id uses a more general mechanism for querying AMIs (although it would probably be possible to query the same parameter store value)
* The IAM Role has a separate policy that is attached rather than adding the policy inline, it's also necessary to separately attach the SSM policy
* The security groups have to specify egress because Terraform removes the default egress that AWS creates
* The user data is declared using a [local](https://www.terraform.io/docs/configuration/locals.html) because it wasn't clear how to directly base64 encode it
