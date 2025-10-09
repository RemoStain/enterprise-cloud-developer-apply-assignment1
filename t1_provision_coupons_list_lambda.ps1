Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Creating Lambda function: coupons_list"

# Prepare build directory and lambda handler
New-Item -ItemType Directory -Force -Path build | Out-Null
@'
import json

def handler(event, context):
    response = {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Sample coupons list response"})
    }
    return response
'@ | Out-File build\coupons_list.py -Encoding utf8

# Zip function 
Compress-Archive -Path build\coupons_list.py -DestinationPath build\coupons_list.zip -Force

# Create Lambda on LocalStack
awslocal lambda create-function `
  --function-name coupons_list `
  --runtime python3.12 `
  --role arn:aws:iam::000000000000:role/coupons_lambda_role `
  --handler coupons_list.handler `
  --zip-file fileb://build/coupons_list.zip | Out-Null

Write-Host "Lambda function 'coupons_list' created successfully."
