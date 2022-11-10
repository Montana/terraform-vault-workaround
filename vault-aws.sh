AWS_ROLE="$1"
VAULT_ROLE="$2"

echo "Attempting AWS to Assume Role for $AWS_ROLE" >&2
aws sts assume-role --role-arn "$AWS_ROLE" \
  --role-session-name vaultSession \
  --duration-seconds 3600 \
  --output=json \
  > ./creds
export AWS_ACCESS_KEY_ID=`jq -r '.Credentials.AccessKeyId' ./creds`
export AWS_SECRET_ACCESS_KEY=`jq -r '.Credentials.SecretAccessKey' ./creds`
export AWS_SESSION_TOKEN=`jq -r '.Credentials.SessionToken' ./creds`
export AWS_EXPIRATION=`jq -r '.Credentials.Expiration' ./creds`
rm ./creds
vault login -method=aws role=$VAULT_ROLE -format=json \
  | jq '{ token: .auth.client_token }'
