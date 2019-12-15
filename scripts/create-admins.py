from argparse import ArgumentParser
import boto3
import secrets
import string

alphabet = string.ascii_letters + string.digits


def create_admin(num):
    name = f'iac{num}'
    session = boto3.Session(profile_name=name, region_name='us-east-2')
    iam = session.client('iam')
    iam.create_user(UserName=name)
    iam.attach_user_policy(UserName=name, PolicyArn='arn:aws:iam::aws:policy/AdministratorAccess')
    password = ''.join(secrets.choice(alphabet) for c in range(10))
    iam.create_login_profile(UserName=name, Password=password)
    access_key = iam.create_access_key(UserName=name)['AccessKey']

    with open(f'credentials/{name}', 'w') as file:
        file.write(f'Console URL: https://{name}.signin.aws.amazon.com/console\n')
        file.write(f'Username: {name}\n')
        file.write(f'Password: {password}\n')
        file.write('\nCLI Credentials (add to ~/.aws/credentials):\n\n')
        file.write(f'[{name}]\n')
        file.write(f'aws_access_key_id = {access_key["AccessKeyId"]}\n')
        file.write(f'aws_secret_access_key = {access_key["SecretAccessKey"]}\n')
        file.write(f'region = us-east-2\n')

    print(f'Created {name}')


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-c', '--count', type=int, help='Account Count', required=True)
    args = parser.parse_args()
    for i in range(args.count):
        create_admin(i+1)
