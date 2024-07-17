#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo 'Error: jq is not installed.' >&2
    exit 1
fi

# Get temporary credentials
credentials=$(curl -H "Authorization: $AWS_CONTAINER_AUTHORIZATION_TOKEN" "$AWS_CONTAINER_CREDENTIALS_FULL_URI" 2>/dev/null)

# Extract values from credentials using jq
expiration=$(echo "$credentials" | jq -r .Expiration)
access_key=$(echo "$credentials" | jq -r .AccessKeyId)
secret_key=$(echo "$credentials" | jq -r .SecretAccessKey)
session_token=$(echo "$credentials" | jq -r .Token)

# Print temporary credentials
print_aws_temp_credentials() {
    local role_name
    role_name=$(aws sts get-caller-identity --query Arn --output text | cut -d '/' -f 2)

    echo -e "\nThis is ${role_name} temporary credential.\nPaste them in your shell! \n"
    echo "export AWS_ACCESS_KEY_ID=${1};"
    echo "export AWS_SECRET_ACCESS_KEY=${2};"
    echo "export AWS_SESSION_TOKEN=${3};"
    echo ""
}

print_aws_temp_credentials "$access_key" "$secret_key" "$session_token"

# Calculate time left for the credentials
expiration_epoch=$(date -d "$expiration" +%s)
now_epoch=$(date +%s)
time_left=$((expiration_epoch - now_epoch))
minutes=$((time_left / 60))
seconds=$((time_left % 60))
echo -e "Time left for the credentials: $minutes minutes and $seconds seconds\n"
