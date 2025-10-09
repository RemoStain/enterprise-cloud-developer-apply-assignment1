Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Adding endpoint /coupons_poc to API Gateway 'coupons'"

# Retrieve API ID and root resource ID
$API_ID = awslocal apigateway get-rest-apis --query "items[?name=='coupons'].id" --output text
$ROOT_ID = awslocal apigateway get-resources --rest-api-id $API_ID --query "items[?path=='/'].id" --output text

# Create resource for /coupons_poc
$RESOURCE_ID = awslocal apigateway create-resource `
  --rest-api-id $API_ID `
  --parent-id $ROOT_ID `
  --path-part coupons_poc `
  --query id --output text

# Create GET method
awslocal apigateway put-method `
  --rest-api-id $API_ID `
  --resource-id $RESOURCE_ID `
  --http-method GET `
  --authorization-type "NONE" | Out-Null

# Link GET method to lambda function
awslocal apigateway put-integration `
  --rest-api-id $API_ID `
  --resource-id $RESOURCE_ID `
  --http-method GET `
  --type AWS_PROXY `
  --integration-http-method POST `
  --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:coupons_list/invocations" | Out-Null

# Deploy API to 'dev' stage
awslocal apigateway create-deployment `
  --rest-api-id $API_ID `
  --stage-name dev | Out-Null

Write-Host "Endpoint '/coupons_poc' added and deployed successfully."
