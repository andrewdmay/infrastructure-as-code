from argparse import ArgumentParser
import boto3


def iam_users(session):
    client = session.client('iam')
    users = client.list_users()
    for user in users.get('Users', []):
        user_name = user['UserName']
        try:
            client.delete_login_profile(UserName=user_name)
        except client.exceptions.NoSuchEntityException:
            pass
        for key in client.list_access_keys(UserName=user_name).get('AccessKeyMetadata', []):
            client.delete_access_key(UserName=user_name, AccessKeyId=key['AccessKeyId'])
        for policy in client.list_attached_user_policies(UserName=user_name).get('AttachedPolicies', []):
            client.detach_user_policy(UserName=user_name, PolicyArn=policy['PolicyArn'])

        client.delete_user(UserName=user_name)
        print(f'Deleted User {user_name}')


def instance_profiles(session):
    client = session.client('iam')
    profiles = client.list_instance_profiles()
    for profile in profiles.get('InstanceProfiles', []):
        profile_name = profile['InstanceProfileName']
        for role in profile['Roles']:
            client.remove_role_from_instance_profile(InstanceProfileName=profile_name, RoleName=role['RoleName'])
        client.delete_instance_profile(InstanceProfileName=profile_name)
        print(f'Deleted Instance Profile {profile_name}')


def iam_roles(session):
    client = session.client('iam')
    roles = client.list_roles()
    for role in roles.get('Roles', []):
        if role['Path'] == '/' and role['RoleName'] != 'OrganizationAccountAccessRole':
            # attached Roles
            for policy in client.list_attached_role_policies(RoleName=role['RoleName']).get('AttachedPolicies', []):
                client.detach_role_policy(RoleName=role['RoleName'], PolicyArn=policy['PolicyArn'])
            # inline Roles
            for policy_name in client.list_role_policies(RoleName=role['RoleName']).get('PolicyNames', []):
                client.delete_role_policy(RoleName=role['RoleName'], PolicyName=policy_name)
            client.delete_role(RoleName=role['RoleName'])
            print(f'Deleted Role {role["RoleName"]}')

    # Clean up (now detached) policies
    policies = client.list_policies(Scope='Local')
    for policy in policies.get('Policies', []):
        versions = client.list_policy_versions(PolicyArn=policy['Arn'])
        for version in versions.get('Versions', []):
            if not version['IsDefaultVersion']:
                client.delete_policy_version(PolicyArn=policy['Arn'], VersionId=version['VersionId'])
        client.delete_policy(PolicyArn=policy['Arn'])
        print(f'Deleted Policy {policy["PolicyName"]}')


def ec2(session):
    client = session.client('ec2')
    reservations = client.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    instance_ids = [instance['InstanceId'] for reservation in reservations['Reservations']
                    for instance in reservation['Instances']]
    if instance_ids:
        print(f'Terminating EC2 instances {instance_ids}')
        client.terminate_instances(InstanceIds=instance_ids)


def key_pairs(session):
    client = session.client('ec2')
    key_pairs = client.describe_key_pairs()
    for key_name in [k['KeyName'] for k in key_pairs.get('KeyPairs', [])]:
        print(f'Deleting Key Pair {key_name}')
        client.delete_key_pair(KeyName=key_name)


def security_groups(session):
    client = session.client('ec2')
    groups = client.describe_security_groups()
    for group in groups.get('SecurityGroups', []):
        if group['GroupName'] != 'default':
            print(f'Deleting Security Group {group["GroupId"]}/{group["GroupName"]}')
            client.delete_security_group(GroupId=group['GroupId'])


def check_region(profile, region):
    print(f'\nChecking {region}')
    session = boto3.session.Session(profile_name=profile, region_name=region)
    iam_users(session)
    instance_profiles(session)
    iam_roles(session)
    ec2(session)
    key_pairs(session)
    security_groups(session)


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-p', '--profile', help='AWS Profile', required=True)
    parser.add_argument('-r', '--regions', help='AWS Regions', nargs="*", default=['us-east-1', 'us-east-2'])

    args = parser.parse_args()
    for region in args.regions:
        check_region(args.profile, region)
