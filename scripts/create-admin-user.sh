#!/bin/bash

user=$1
pass=$2
profile=$3

aws iam create-user --user-name $user --profile $profile
aws iam attach-user-policy --user-name $user --policy-arn 'arn:aws:iam::aws:policy/AdministratorAccess' --profile $profile
aws iam create-login-profile --user-name $user --password $pass --profile $profile
aws iam create-access-key --user-name $user --profile $profile
