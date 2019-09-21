from aws_cdk import (
    aws_ec2 as ec2,
    core
)

class SimpleVpcStack(core.Stack):

    def __init__(self, scope: core.Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        public = ec2.SubnetConfiguration(
            name='Public', subnet_type=ec2.SubnetType.PUBLIC
        )

        vpc = ec2.Vpc(self, 'CDKVpc',
            cidr='10.200.0.0/16',
            max_azs=3,
            subnet_configuration=[ public ])
