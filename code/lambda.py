import os
import json
import boto3
import logging
import re
import datetime

# Use the table name from environment variable, which should be set to 'app_data'
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def is_malicious(app_name, description):
    # Basic malicious request detection
    patterns = [
        r"(\b(select|insert|delete|update|drop)\b)",
        r"<script>",
        r"(--|\bOR\b|\bAND\b)"
    ]
    for pattern in patterns:
        if re.search(pattern, app_name, re.IGNORECASE) or re.search(pattern, description, re.IGNORECASE):
            return True
    return False

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    try:
        headers = event.get('headers', {})
        origin = headers.get('origin', '')
        if not re.match(r"^https:\/\/[a-zA-Z0-9\-]+\.testdevops\.com$", origin):
            logger.warning(f"Rejected request from origin: {origin}")
            return {
                "statusCode": 403,
                "headers": {"Access-Control-Allow-Origin": "*.testdevops.com"},
                "body": json.dumps({"error": "Forbidden"})
            }

        # Authentication is handled by API Gateway + Cognito
        # Optionally extract user info from Cognito claims
        user = None
        try:
            user = event['requestContext']['authorizer']['claims']['sub']
        except Exception:
            user = "unknown"

        body = json.loads(event.get('body', '{}'))
        app_name = body.get('AppName', '')
        rating = body.get('Rating', '')
        description = body.get('Description', '')

        errors = []
        if not app_name or len(app_name) > 50:
            errors.append('AppName is required and must be at most 50 characters.')
        try:
            rating = int(rating)
            if rating < 1 or rating > 5:
                errors.append('Rating must be an integer between 1 and 5.')
        except Exception:
            errors.append('Rating must be an integer between 1 and 5.')
        if not description or len(description) > 2000:
            errors.append('Description is required and must be at most 2000 characters.')
        if is_malicious(app_name, description):
            logger.error("Malicious request detected")
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*.testdevops.com"},
                "body": json.dumps({"error": "Malicious request detected"})
            }
        if errors:
            logger.error(f"Validation failed: {errors}")
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*.testdevops.com"},
                "body": json.dumps({"errors": errors})
            }

        create_date = datetime.datetime.utcnow().isoformat()
        table.put_item(Item={
            'AppName': app_name,
            'CreateDate': create_date,
            'Rating': rating,
            'Description': description,
            'UserId': user
        })
        logger.info(f"Saved rating for {app_name} at {create_date} by user {user}")
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*.testdevops.com"},
            "body": json.dumps({"status": "success"})
        }
    except Exception as e:
        logger.error(f"Unhandled exception: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*.testdevops.com"},
            "body": json.dumps({"error": "Internal server error"})
        }
