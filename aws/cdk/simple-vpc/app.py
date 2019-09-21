#!/usr/bin/env python3

from aws_cdk import core

from simple_vpc.simple_vpc_stack import SimpleVpcStack

dev=core.Environment(account='648758314004', region='us-east-2')

app = core.App()
SimpleVpcStack(app, "simple-vpc", env=dev)

app.synth()
