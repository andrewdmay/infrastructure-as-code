#!/usr/bin/env python3

import os
from aws_cdk import core

from simple_vpc.simple_vpc_stack import SimpleVpcStack

dev=core.Environment(account=os.environ['CDK_DEFAULT_ACCOUNT'],
                     region=os.environ['CDK_DEFAULT_REGION'])

app = core.App()
SimpleVpcStack(app, "simple-vpc", env=dev)

app.synth()
