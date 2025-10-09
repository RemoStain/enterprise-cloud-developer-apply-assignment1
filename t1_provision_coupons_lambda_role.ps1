Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Creating IAM role: coupons_lambda_role"

# Create assume-role trus policy
@'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
'@ | Out-File assume-role-policy.json -Encoding utf8


awslocal iam create-role `
  --role-name coupons_lambda_role `
  --assume-role-policy-document file://assume-role-policy.json | Out-Null


@'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchAccessCouponsLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:000000000000:log-group:/aws/lambda/coupons*:*"
    },
    {
      "Sid": "DynamoDBCouponsTableAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:000000000000:table/coupons"
    }
  ]
}
'@ | Out-File coupons-role-policy.json -Encoding utf8

awslocal iam put-role-policy `
  --role-name coupons_lambda_role `
  --policy-name coupons_policy `
  --policy-document file://coupons-role-policy.json | Out-Null

Write-Host "IAM role 'coupons_lambda_role' created and configured successfully."
